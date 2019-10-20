//
//  StatisticsData.swift
//  Devoured
//
//  Created by Jing Su on 10/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class StatisticsData: NSObject, NSCoding {
    
    var stepsGoal: Int
    var highestScore: Int
    var gameTriedCount: Int
    var currentLives: Int
    var lastExchangeLifeTimestamp: Int
    
    init(stepsGoal: Int = 1000, highestScore: Int = 0, gameTriedCount: Int = 0, currentLives: Int = 0, lastExchangeLifeTimestamp: Int = 0) {
        self.stepsGoal = stepsGoal
        self.highestScore = highestScore
        self.gameTriedCount = gameTriedCount
        self.currentLives = currentLives
        self.lastExchangeLifeTimestamp = lastExchangeLifeTimestamp
    }
    
    required init(coder decoder: NSCoder) {
        self.stepsGoal = decoder.decodeInteger(forKey: "stepsGoal")
        self.highestScore = decoder.decodeInteger(forKey: "highestScore")
        self.gameTriedCount = decoder.decodeInteger(forKey: "gameTriedCount")
        self.currentLives = decoder.decodeInteger(forKey: "currentLives")
        self.lastExchangeLifeTimestamp = decoder.decodeInteger(forKey: "lastExchangeLifeTimestamp")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(stepsGoal, forKey: "stepsGoal")
        coder.encode(highestScore, forKey: "highestScore")
        coder.encode(gameTriedCount, forKey: "gameTriedCount")
        coder.encode(currentLives, forKey: "currentLives")
        coder.encode(lastExchangeLifeTimestamp, forKey: "lastExchangeLifeTimestamp")
    }
    
}
