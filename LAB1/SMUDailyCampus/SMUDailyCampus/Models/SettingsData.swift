//
//  SettingsData.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class SettingsData: NSObject, NSCoding {
    
    var autoRenderMode: Bool
    var titleBarDarkStyle: Bool
    var titleBarFontSize: Double
    var autoRefreshInterval: Double
    var titleIndex: Int
    let titleChoices = [
        "SMU Daily Campus",
        "Daily Campus",
        "Peruna Daily",
        "SMU Daily"
    ]
    
    init(autoRenderMode: Bool = true, titleBarDarkStyle: Bool = false, titleBarFontSize: Double = 32, autoRefreshInterval: Double = 10, titleIndex: Int = 0) {
        self.autoRenderMode = autoRenderMode
        self.titleBarDarkStyle = titleBarDarkStyle
        self.titleBarFontSize = titleBarFontSize
        self.autoRefreshInterval = autoRefreshInterval
        self.titleIndex = titleIndex
    }
    
    required init(coder decoder: NSCoder) {
        self.autoRenderMode = decoder.decodeBool(forKey: "autoRenderMode")
        self.titleBarDarkStyle = decoder.decodeBool(forKey: "titleBarDarkStyle")
        self.titleBarFontSize = decoder.decodeDouble(forKey: "titleBarFontSize")
        self.autoRefreshInterval = decoder.decodeDouble(forKey: "autoRefreshInterval")
        self.titleIndex = decoder.decodeInteger(forKey: "titleIndex")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(autoRenderMode, forKey: "autoRenderMode")
        coder.encode(titleBarDarkStyle, forKey: "titleBarDarkStyle")
        coder.encode(titleBarFontSize, forKey: "titleBarFontSize")
        coder.encode(autoRefreshInterval, forKey: "autoRefreshInterval")
        coder.encode(titleIndex, forKey: "titleIndex")
    }
    
    func getCurrentTitle() -> String {
        if titleIndex < titleChoices.count {
            return titleChoices[titleIndex]
        }
        return titleChoices.first!
    }
    
}
