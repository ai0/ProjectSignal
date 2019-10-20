//
//  StatisticsDataManager.swift
//  Devoured
//
//  Created by Jing Su on 10/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class StatisticsDataManager {
    
    static let shared = StatisticsDataManager()
    
    var statistics: StatisticsData
    
    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "StatisticsData") {
            do {
                if let unarchivedStatisticsData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? StatisticsData {
                    statistics = unarchivedStatisticsData
                    return
                }
            } catch {}
        }
        statistics = StatisticsData()
    }
    
    func save() {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: statistics, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "StatisticsData")
        } catch {
            return
        }
    }
    
    func reset() {
        statistics.highestScore = 0
        statistics.gameTriedCount = 0
        save()
    }
    
}
