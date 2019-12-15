//
//  SceneViewController.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion
import CoreLocation
import SwiftUI

/* There are too many bugs on SwiftUI and it is so unmature,
   I have to use hybrid SwiftUI and UIKit

   SwiftUI works terrible with ARSCNView,
   the UIViewControllerRepresentable won't works well too*/

class SceneViewController: UIViewController, ARSessionDelegate, BeaconsDelegate {
    
    private let previewContent = PreviewContent()
    private var detailViewVC: UIViewController!
    private var postMenuVC: UIViewController!
    private var openedModal: UIViewController?
    
    private var currentLocationCoordinate: CLLocationCoordinate2D? {
        didSet {
            if settingsManage.settings.stepsToUpdateScene < 1 {
                updateBeacons()
                loadBeacons()
            }
        }
    }
    private var gpsLocationCoordinate: CLLocationCoordinate2D?
    private var isLocationLocked: Bool = false
    
    private let settingsManage: SettingsManage = .shared
    private var beaconsManage: BeaconsManage!

    // Client
    private var beaconsClient = BeaconsClient()
    
    // LocationNet
    private let locationNetService = LocationNetService()
    private let landmarksNetService = LocationNetService()
    
    // Gyroscope
    private let pedometer = CMPedometer()
    
    // GPS
    private let locationManager = CLLocationManager()
    
    // Haptic Feedback
    private let notification = UINotificationFeedbackGenerator()

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var locationIndicator: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.session.delegate = self
        
        // Capture tap event
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        sceneView.addGestureRecognizer(tapRec)
        
        // CoreML
        locationNetService.setup(for: RN1015k500().model)
        locationNetService.delegate = self
        landmarksNetService.setup(for: SMULandmarks().model)
        landmarksNetService.delegate = self
        
        // CoreLocation
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // Init the SwiftUI view
        detailViewVC = UIHostingController(rootView: DetailView(delegate: self).environmentObject(previewContent))
        
        startMonitorUserMove()
        
        sceneView.session.run(ARWorldTrackingConfiguration())
        
        beaconsManage = BeaconsManage(scene: sceneView.scene)
        beaconsClient.beaconsDelegate = self
    }
    
    // MARK: Camera Frame
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        struct State {
            static var lastTimeStamp: Double = 0
        }
        
        if frame.timestamp - State.lastTimeStamp > settingsManage.settings.locationPredictionInterval {
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                
                //                    Explanation
                /*
                    The following if statement here is to meet the project requirement (for demonstration, at least five locations will be supported on the SMU campus)
                 
                    Since the original training dataset of LocationNet did not include the SMU campus images and coordinates and re-training the LocationNet will cost 9 days on 16 NVIDIA K80 GPUs (p2.16xlarge EC2 instance) with 12 epochs[1]. With my current hardware conditions, it will take months for training. It is impossible to achieve it before the final project due time.
                 
                    Therefore I trained a separate SMU campus only model to predict the GPS coordinates and use this model when the current GPS coordinates are inside the SMU campus.
                 
                    References:
                    [1] https://aws.amazon.com/blogs/machine-learning/estimating-the-location-of-images-using-mxnet-and-multimedia-commons-dataset-on-aws-ec2/
                */
                
                if self?.gpsLocationCoordinate?.isInsideSMUCampus() ?? false {
                    self?.landmarksNetService.predict(image: frame.capturedImage)
                } else {
                    self?.locationNetService.predict(image: frame.capturedImage)
                }
            }
            State.lastTimeStamp = frame.timestamp
        }
    }

    // MARK: Hanle user select
    // (MOD Constraint) When a user selects and image or text in the AR scene, it will be displayed full screen for the user to view and explore.
    
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: [
                SCNHitTestOption.firstFoundOnly: true,
                SCNHitTestOption.boundingBoxOnly: true])
            if !hits.isEmpty {
                let tappedNode = hits.first?.node
                if ["text", "image"].contains(tappedNode?.name ?? "") {
                    if let geometry = tappedNode?.geometry {
                        if geometry is SCNText {
                            previewContent.textContent = (geometry as! SCNText).string as? String
                        } else {
                            previewContent.imageContent = (geometry as! SCNPlane).firstMaterial?.diffuse.contents as? UIImage
                        }
                        presentModal(detailViewVC, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: Monitor User Move
    
    func startMonitorUserMove() {
        struct State {
            static var lastTimeSteps: Double = 0
        }
        
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            DispatchQueue.global(qos: .background).async {
                State.lastTimeSteps += pedometerData.numberOfSteps.doubleValue
                if State.lastTimeSteps > SettingsManage.shared.settings.stepsToUpdateScene {
                    self?.updateBeacons()
                    self?.loadBeacons()
                    State.lastTimeSteps = 0
                    self?.notification.notificationOccurred(.success)
                }
            }
        }
    }
    
    // MARK: Interface Actions
    
    func presentModal(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        openedModal = viewControllerToPresent
        present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    @IBAction func refreshScene(_ sender: UIButton) {
        updateBeacons()
    }
    
    
    @IBAction func lockLocation(_ sender: UIButton) {
        isLocationLocked.toggle()
        sender.setImage(UIImage(named: isLocationLocked ? "lock" : "unlock"), for: .normal)
    }
    
    
    @IBAction func locationDetail(_ sender: UIButton) {
        if currentLocationCoordinate != nil {
            previewContent.locationCoordinate = currentLocationCoordinate
        } else {
            previewContent.textContent = "NO LOCATION DATA"
        }
        presentModal(detailViewVC, animated: true)
    }
    
    
    @IBAction func postItem(_ sender: UIButton) {
        guard currentLocationCoordinate != nil else {
            let alert = UIAlertController(title: "Please Wait", message: "Location information unavailable.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        let postMenuVC = UIHostingController(rootView: PostMenuView(delegate: self, currentLocationCoordinate: currentLocationCoordinate!, beaconsManage: beaconsManage))
        presentModal(postMenuVC, animated: true)
    }
    
    // MARK: AR Related
    
    func updateBeacons() {
        guard currentLocationCoordinate != nil else { return }
        if !beaconsClient.isConnected {
            guard beaconsClient.connect() else {
                let alert = UIAlertController(title: "Connection Lost", message: "Unable to establish WebSocket connection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
                return
            }
        }
        beaconsClient.updateBeacons(latitude: currentLocationCoordinate!.latitude, longitude: currentLocationCoordinate!.longitude, limit: settingsManage.settings.maximumObjectPerScene)
    }
    
    func loadBeacons() {
        struct State {
            static var mutexLock: Bool = false
        }
        
        if !State.mutexLock {
            State.mutexLock = true
            beaconsManage.clearNodes()
            let beacons = beaconsClient.beacons
            for beacon in beacons {
                if beacon.type == .Text {
                    beaconsManage.addTextNode(verbatim: beacon.text!)
                } else {
                    beaconsManage.addImageNode(image: beacon.image!)
                }
            }
            State.mutexLock = false
        }
    }

}

// Callback for SwiftUI view
extension SceneViewController: DismissDelegate {
    func dismissModal() {
        openedModal?.dismiss(animated: true)
    }
}

// MARK: LocationNet Delegate

extension SceneViewController: LocationNetServiceDelegate {
    func locationNetService(_ service: LocationNetService, didPredictLocation location: [(String, Double)]) {
        struct State {
            static var lastTimeLocaltionLabel: String = ""
        }
        
        guard location.count > 0 else { return }
        let latLongArr = location[0].0.components(separatedBy: "\t")
        DispatchQueue.main.async {
            self.locationIndicator.fadeTransition(0.6)
            self.locationIndicator.text = latLongArr[0]
        }
        DispatchQueue.global(qos: .background).async {
            if latLongArr[0] != State.lastTimeLocaltionLabel {
                self.notification.notificationOccurred(.success)
                State.lastTimeLocaltionLabel = latLongArr[0]
            }
        }
        if !settingsManage.settings.locationByGPS && !isLocationLocked {
            let latitude = Double(latLongArr[1]),
                longitude = Double(latLongArr[2])
            let newLocationCoordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            if currentLocationCoordinate == nil || newLocationCoordinate.distanceInMeters(to: currentLocationCoordinate!) > GPS_OFFSET_TOLERATE {
                currentLocationCoordinate = newLocationCoordinate
            }
        }
    }
}

// MARK: LocationManager Delegate

extension SceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        gpsLocationCoordinate = locValue
        if settingsManage.settings.locationByGPS && !isLocationLocked {
            if currentLocationCoordinate == nil || gpsLocationCoordinate!.distanceInMeters(to: currentLocationCoordinate!) > GPS_OFFSET_TOLERATE {
                currentLocationCoordinate = gpsLocationCoordinate
            }
        }
    }
}

// MARK: ARSCNView Delegate

extension SceneViewController: ARSCNViewDelegate {
    

    
}

