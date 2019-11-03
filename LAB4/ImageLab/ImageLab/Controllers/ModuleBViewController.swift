//
//  ModuleBViewController.swift
//  ImageLab
//
//  Created by Jing Su on 10/25/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

class ModuleBViewController: UIViewController {
    
    var videoManager: VideoAnalgesic! = nil
    let bridge = OpenCVPPGBridge()
    
    var cyclesToCalcHeartRate = 0
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var ppgChart: LineChartView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        videoManager = VideoAnalgesic.sharedInstance
        setupChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning {
            videoManager.start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoManager.turnOffFlash()
    }
    
    func setupChart() {
        ppgChart.noDataText = "Please cover the back camera and flashlight with your forefinger."
        ppgChart.noDataTextColor = UIColor.red
        ppgChart.noDataTextAlignment = .center
        ppgChart.noDataFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
        
        ppgChart.leftAxis.drawLabelsEnabled = false
        ppgChart.rightAxis.drawLabelsEnabled = false
        ppgChart.leftAxis.drawGridLinesEnabled = false
        ppgChart.rightAxis.drawGridLinesEnabled = false
        ppgChart.leftAxis.drawAxisLineEnabled = false
        ppgChart.rightAxis.drawAxisLineEnabled = false
        ppgChart.xAxis.drawAxisLineEnabled = false
        ppgChart.xAxis.drawLabelsEnabled = false
        ppgChart.xAxis.drawGridLinesEnabled = false
        ppgChart.drawBordersEnabled = false
        ppgChart.legend.enabled = false
    }
    
    func processImage(inputImage:CIImage) -> CIImage {
        let _ = videoManager.turnOnFlashwithLevel(1.0)
        var retImage = inputImage
        
        self.bridge.setTransforms(self.videoManager.transform)
        self.bridge.setImage(retImage,
                             withBounds: retImage.extent,
                            andContext: self.videoManager.getCIContext())
        self.bridge.processImage()
        retImage = self.bridge.getImageComposite()
        
        if bridge.hasEnoughData() {
            if (cyclesToCalcHeartRate == 0) {
                DispatchQueue.main.async {
                    self.heartRateLabel.text = "\(self.bridge.calcHeartRate())"
                }
                cyclesToCalcHeartRate = 30
            } else {
                cyclesToCalcHeartRate -= 1
            }
            
            let redArray = bridge.getRedArray() as! [NSNumber]
            
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<redArray.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: redArray[i].doubleValue)
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = LineChartDataSet(entries: dataEntries)
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawValuesEnabled = false
            chartDataSet.setColor(UIColor(red: 1.00, green: 0.56, blue: 0.61, alpha: 1.00))
            chartDataSet.lineWidth = 3.0
            let chartData = LineChartData(dataSet: chartDataSet)
            
            DispatchQueue.main.async {
                self.ppgChart.data = chartData
            }
        }
        
        return retImage
    }

}

