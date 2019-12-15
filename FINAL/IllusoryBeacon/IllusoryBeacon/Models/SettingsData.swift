//
//  SettingsData.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class SettingsData: NSObject, NSCoding {
    
    var locationByGPS: Bool
    var locationPredictionInterval: Double
    var stepsToUpdateScene: Double
    var maximumObjectPerScene: Int
    
    init(locationByGPS: Bool = true, locationPredictionInterval: Double = 6, stepsToUpdateScene: Double = 15, maximumObjectPerScene: Int = 6) {
        self.locationByGPS = locationByGPS
        self.locationPredictionInterval = locationPredictionInterval
        self.stepsToUpdateScene = stepsToUpdateScene
        self.maximumObjectPerScene = maximumObjectPerScene
    }
    
    required init(coder decoder: NSCoder) {
        self.locationByGPS = decoder.decodeBool(forKey: "locationByGPS")
        self.locationPredictionInterval = decoder.decodeDouble(forKey: "locationPredictionInterval")
        self.stepsToUpdateScene = decoder.decodeDouble(forKey: "stepsToUpdateScene")
        self.maximumObjectPerScene = decoder.decodeInteger(forKey: "maximumObjectPerScene")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(locationByGPS, forKey: "locationByGPS")
        coder.encode(locationPredictionInterval, forKey: "locationPredictionInterval")
        coder.encode(stepsToUpdateScene, forKey: "stepsToUpdateScene")
        coder.encode(maximumObjectPerScene, forKey: "maximumObjectPerScene")
    }
    
}

