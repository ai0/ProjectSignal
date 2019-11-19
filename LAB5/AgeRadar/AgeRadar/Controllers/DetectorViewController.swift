//
//  DetectorViewController.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import AVFoundation

class DetectorViewController: UIViewController {
    
    private let mlServiceClient: MLServiceClient = .shared
    private let settingsManage: SettingsManage = .shared
    
    var videoManager: VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    
    let cmlDetectionService = DetectionService()
    
    var cyclesToProcess = 0
    
    @IBOutlet weak var modelResultLabel: UILabel!
    @IBOutlet weak var agenetResultLabel: UILabel!
    @IBOutlet weak var trainBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = nil
        
        videoManager = VideoAnalgesic.sharedInstance
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh,
                            CIDetectorTracking:true] as [String : Any]
        detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: videoManager.getCIContext(),
                                   options: (optsDetector as [String : AnyObject]))
        
        cmlDetectionService.setup()
        cmlDetectionService.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning {
            videoManager.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func hasOnlyOneFace(_ img: CIImage) -> Bool {
        let optsFace = [CIDetectorImageOrientation:self.videoManager.ciOrientation]
        let faces: [CIFaceFeature] = detector.features(in: img, options: optsFace).compactMap({ $0 as? CIFaceFeature })
        // detect when only one face existed to avoid ambiguous
        return faces.count == 1
    }
    
    func processImage(inputImage: CIImage) -> CIImage {
        var retImage = inputImage
        
        // mirror the image when using the front camera for natural feel
        if (videoManager.getCameraPosition() == AVCaptureDevice.Position.front) {
            retImage = inputImage.oriented(.leftMirrored).oriented(.left)
        }
    
        if hasOnlyOneFace(retImage) {
            if (cyclesToProcess == 0) {
                serverDetection(retImage)
                cmlDetection(retImage)
                cyclesToProcess = 30
                
            } else {
                cyclesToProcess -= 1
            }
            setTrainingBtnStatus(enabled: true)
        } else {
            resetResultLabel()
            setTrainingBtnStatus(enabled: false)
        }

        return retImage
    }
    
    func resetResultLabel() {
        DispatchQueue.main.async { [weak self] in
            self?.modelResultLabel.text = "N/A"
            self?.agenetResultLabel.text = "N/A"
        }
    }
    
    func setTrainingBtnStatus(enabled: Bool) {
        if enabled {
            DispatchQueue.main.async { [weak self] in
                self?.trainBtn.setTitle("Train Model", for: .normal)
                self?.trainBtn.backgroundColor = UIColor.systemBlue
                self?.trainBtn.isEnabled = true
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.trainBtn.setTitle("NO FACE", for: .disabled)
                self?.trainBtn.backgroundColor = UIColor.lightGray
                self?.trainBtn.isEnabled = false
            }
        }
    }
    
    func cmlDetection(_ img: CIImage) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
          self?.cmlDetectionService.detect(image: img)
        }
    }
    
    func serverDetection(_ img: CIImage) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            var croppedImage = self?.videoManager.getSnapshot().fixOrientation()
            croppedImage!.face.crop { result in
                switch result {
                case .success(let faces):
                    croppedImage = faces.first!
                case .notFound:
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
            let age = self?.mlServiceClient.predict(with: croppedImage!, and: (self?.settingsManage.settings.imageQuality)!)
            DispatchQueue.main.async { [weak self] in
                self?.modelResultLabel.text = age
            }
        }
    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
        videoManager.toggleCameraPosition()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainModelSegue" {
            let trainModelViewController = segue.destination as! TrainModelViewController
            let image = videoManager.getSnapshot().fixOrientation()
            image.face.crop { result in
                switch result {
                case .success(let faces):
                    trainModelViewController.snapshotImage = faces.first
                case .notFound:
                    trainModelViewController.snapshotImage = image
                case .failure(let error):
                    trainModelViewController.snapshotImage = image
                    print(error)
                }
            }
        }
    }

}

extension DetectorViewController: DetectionServiceDelegate {
    func detectionService(_ service: DetectionService, didDetectAge age: String) {
        DispatchQueue.main.async { [weak self] in
            self?.agenetResultLabel.text = age
        }
    }
}
