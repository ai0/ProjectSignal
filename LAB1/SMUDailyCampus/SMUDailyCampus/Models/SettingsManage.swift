//
//  SettingsManage.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class SettingsManage {
    
    static let shared = SettingsManage()
    
    var settings: SettingsData
    
    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "SettingsManageData") {
            do {
                if let unarchivedSettings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SettingsData {
                    settings = unarchivedSettings
                    return
                }
            } catch {}
        }
        settings = SettingsData()
    }
    
    func save() {
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: settings, requiringSecureCoding: false)
            UserDefaults.standard.set(encodedData, forKey: "SettingsManageData")
        } catch {
            return
        }
    }
    
    func reset() {
        settings =  SettingsData()
        save()
    }
    
}

