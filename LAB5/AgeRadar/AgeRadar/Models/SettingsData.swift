//
//  SettingsData.swift
//  AgeRadar
//
//  Created by Jing Su on 11/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class SettingsData: NSObject, NSCoding {
    
    var username: String
    var password: String
    var imageQuality: Float
    var mlAlgorithm: String
    var kNNNeighbors: Int
    
    init(username: String = "", password: String = "", imageQuality: Float = 0.75, mlAlgorithm: String = "KNN", kNNNeighbors: Int = 1) {
        self.username = username
        self.password = password
        self.imageQuality = imageQuality
        self.mlAlgorithm = mlAlgorithm
        self.kNNNeighbors = kNNNeighbors
    }
    
    required init(coder decoder: NSCoder) {
        self.username = decoder.decodeObject(forKey: "username") as! String
        self.password = decoder.decodeObject(forKey: "password") as! String
        self.imageQuality = decoder.decodeFloat(forKey: "imageQuality")
        self.mlAlgorithm = decoder.decodeObject(forKey: "mlAlgorithm") as! String
        self.kNNNeighbors = decoder.decodeInteger(forKey: "kNNNeighbors")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(username, forKey: "username")
        coder.encode(password, forKey: "password")
        coder.encode(imageQuality, forKey: "imageQuality")
        coder.encode(mlAlgorithm, forKey: "mlAlgorithm")
        coder.encode(kNNNeighbors, forKey: "kNNNeighbors")
    }
    
}
