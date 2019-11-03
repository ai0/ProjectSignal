//
//  ModuleAViewController.swift
//  ImageLab
//
//  Created by Jing Su on 10/25/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import AVFoundation

class ModuleAViewController: UIViewController {
    
    //MARK: Class Properties
    var faceFilter: CIFilter! = nil
    var eyeFilter: CIFilter! = nil
    var mouthFilter: CIFilter! = nil

    var videoManager: VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    
    var enableFacesDetection = false
    var enableEyeAndMouthDetection = false
    
    var lastCycleLeftEyeClosed = false
    var lastCycleRightEyeClosed = false
    var cyclesToDetectBlink = 0
    
    //MARK: Outlets
    @IBOutlet weak var smileStatusLabel: UILabel!
    @IBOutlet weak var eyeBlinkStatusLabel: UILabel!

    //MARK: ViewController Hierarchy
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = nil
        setupFilters()
        
        videoManager = VideoAnalgesic.sharedInstance
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh,
                            CIDetectorTracking:true] as [String : Any]
        detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: videoManager.getCIContext(),
                                   options: (optsDetector as [String : AnyObject]))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning {
            videoManager.start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK: Setup filtering
    func setupFilters(){
        faceFilter = CIFilter(name: "CITwirlDistortion")
        eyeFilter = CIFilter(name: "CIVortexDistortion", parameters: ["inputAngle": 56.55])
        mouthFilter = CIFilter(name: "CIBumpDistortion", parameters: ["inputScale": 0.5])
    }
    
    //MARK: Apply filters and apply feature detectors
    func applyFilters(inputImage:CIImage, features:[CIFaceFeature])->CIImage {
        var retImage = inputImage
        var filterCenter = CGPoint()
        
        for f in features {
            //set where to apply filter
            filterCenter.x = f.bounds.midX
            filterCenter.y = f.bounds.midY
            
            // Highlight face
            if enableFacesDetection {
                faceFilter.setValue(retImage, forKey: kCIInputImageKey)
                faceFilter.setValue(CIVector(cgPoint: filterCenter), forKey: "inputCenter")
                faceFilter.setValue(f.bounds.width/2, forKey: "inputRadius")
                retImage = faceFilter.outputImage!
            }
            
            if enableEyeAndMouthDetection {
            
                if (f.hasLeftEyePosition) {
                    eyeFilter.setValue(retImage, forKey: kCIInputImageKey)
                    eyeFilter.setValue(CIVector(cgPoint: f.leftEyePosition), forKey: "inputCenter")
                    eyeFilter.setValue(f.bounds.width/8, forKey: "inputRadius")
                    retImage = eyeFilter.outputImage!
                }
                
                if (f.hasRightEyePosition) {
                    eyeFilter.setValue(retImage, forKey: kCIInputImageKey)
                    eyeFilter.setValue(CIVector(cgPoint: f.rightEyePosition), forKey: "inputCenter")
                    eyeFilter.setValue(f.bounds.width/8, forKey: "inputRadius")
                    retImage = eyeFilter.outputImage!
                }
                
                if (f.hasMouthPosition) {
                    mouthFilter.setValue(retImage, forKey: kCIInputImageKey)
                    mouthFilter.setValue(CIVector(cgPoint: f.mouthPosition), forKey: "inputCenter")
                    mouthFilter.setValue(f.bounds.width/4, forKey: "inputRadius")
                    retImage = mouthFilter.outputImage!
                }
            }
        }
        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature] {
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorImageOrientation: self.videoManager.ciOrientation,
                        CIDetectorSmile: true,
                        CIDetectorEyeBlink: true] as [String : Any]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    //MARK: Smile and Blink Detection
    func detectSmileAndBlink(feature: CIFaceFeature) {
        if (feature.hasSmile) {
            DispatchQueue.main.async {
                self.smileStatusLabel.text = "Smiling"
                self.smileStatusLabel.backgroundColor = UIColor.green
            }
        } else {
            DispatchQueue.main.async {
                self.smileStatusLabel.text = "Not Smile"
                self.smileStatusLabel.backgroundColor = UIColor.gray
            }
        }
        
        if (cyclesToDetectBlink == 0) {
            var blinkStatus: UInt8 = 0 // 00000000
            if (feature.leftEyeClosed) {
                lastCycleLeftEyeClosed = true
            } else{
                if lastCycleLeftEyeClosed {
                    blinkStatus += 1
                }
                lastCycleLeftEyeClosed = false
            }
            
            if (feature.rightEyeClosed) {
                lastCycleRightEyeClosed = true
            } else {
                if lastCycleRightEyeClosed {
                    blinkStatus += 2
                }
                lastCycleRightEyeClosed = false
            }
            
            
            switch blinkStatus {
            case 1:
                DispatchQueue.main.async {
                    self.eyeBlinkStatusLabel.text = "L Blinking" // Left Blinking
                    self.eyeBlinkStatusLabel.backgroundColor = UIColor.green
                }
            case 2:
                DispatchQueue.main.async {
                    self.eyeBlinkStatusLabel.text = "R Blinking" // Right Blinking
                    self.eyeBlinkStatusLabel.backgroundColor = UIColor.green
                }
            case 3:
                DispatchQueue.main.async {
                    self.eyeBlinkStatusLabel.text = "L&R Blinking" // Both Blinking
                    self.eyeBlinkStatusLabel.backgroundColor = UIColor.green
                }
            default:
                DispatchQueue.main.async {
                    self.eyeBlinkStatusLabel.text = "Not Blink"
                    self.eyeBlinkStatusLabel.backgroundColor = UIColor.gray
                }
            }
            
            cyclesToDetectBlink = 3
        } else {
            cyclesToDetectBlink -= 1
        }
    }
    
    func resetSmileAndBlinkLabels() {
        DispatchQueue.main.async {
            self.smileStatusLabel.text = "Not Smile"
            self.smileStatusLabel.backgroundColor = UIColor.gray
            
            self.eyeBlinkStatusLabel.text = "Not Blink"
            self.eyeBlinkStatusLabel.backgroundColor = UIColor.gray
        }
    }
    
    //MARK: Process image output
    func processImage(inputImage:CIImage) -> CIImage {
        var retImage = inputImage
        
        // mirror the image when using the front camera for natural feel
        if (videoManager.getCameraPosition() == AVCaptureDevice.Position.front) {
            retImage = inputImage.oriented(.leftMirrored).oriented(.left)
        }
        
        // detect faces
        let faces = getFaces(img: retImage)
        
        // if no faces, just return original image
        if faces.count == 0 {
            resetSmileAndBlinkLabels()
            return retImage
        }
        
        // detect smile and blink when only one face existed to avoid ambiguous
        if faces.count == 1 { detectSmileAndBlink(feature: faces.first!) }
        else { resetSmileAndBlinkLabels() }
        
        //otherwise apply the filters to the faces
        return applyFilters(inputImage: retImage, features: faces)
    }

    //MARK: UI Actions
    
    @IBAction func toggleFacesDetection(_ sender: UISwitch) {
        enableFacesDetection = !enableFacesDetection
    }
    
    @IBAction func toggleEyeAndMouthDetection(_ sender: UISwitch) {
        enableEyeAndMouthDetection = !enableEyeAndMouthDetection
    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
        videoManager.toggleCameraPosition()
    }
    
}

