//
//  SettingsObservable.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Combine
import SwiftUI

final class SettingsObservable: ObservableObject {
    
    private let settingsManage: SettingsManage = .shared
    @Published var locationByGPS: Int = SettingsManage.shared.settings.locationByGPS ? 0:1 {
        didSet {
            settingsManage.settings.locationByGPS = Bool(locationByGPS == 0)
            settingsManage.save()
        }
    }
    @Published var locationPredictionInterval: Double = SettingsManage.shared.settings.locationPredictionInterval {
        didSet {
            settingsManage.settings.locationPredictionInterval = locationPredictionInterval
            settingsManage.save()
        }
    }
    @Published var stepsToUpdateScene: Double = SettingsManage.shared.settings.stepsToUpdateScene {
        didSet {
            settingsManage.settings.stepsToUpdateScene = stepsToUpdateScene
            settingsManage.save()
        }
    }
    @Published var maximumObjectPerScene: Double = Double(SettingsManage.shared.settings.maximumObjectPerScene) {
        didSet {
            settingsManage.settings.maximumObjectPerScene = Int(maximumObjectPerScene)
            settingsManage.save()
        }
    }

}
