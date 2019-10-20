//
//  DashboardViewController.swift
//  Devoured
//
//  Created by Jing Su on 10/13/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import CoreMotion

class DashboardViewController: UIViewController {
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    // Haptic Feedback
    private let notification = UINotificationFeedbackGenerator()
    private let statisticsDataManager: StatisticsDataManager = .shared

    private lazy var yesterdaySteps = 0
    private lazy var todaySteps = 0

    @IBOutlet weak var yesterdayStepsLabel: UILabel!
    @IBOutlet weak var todayStepsLabel: UILabel!
    @IBOutlet weak var currentActivityLabel: UILabel!
    @IBOutlet weak var goalProgressLabel: UILabel!
    @IBOutlet weak var goalProgressBar: UIProgressView!
    @IBOutlet weak var playDevouredBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateStepsCount()
        startCountingSteps()
        startTrackingCurrentActivity()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if CMPedometer.isStepCountingAvailable() {
            self.pedometer.stopUpdates()
        }
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.stopActivityUpdates()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private func updateStepsCount() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        let dateNow = Date()
        let startOfToday = Calendar.current.startOfDay(for: dateNow)
        let startOfYesterday = startOfToday.addingTimeInterval(-1*60*60*24)
        self.pedometer.queryPedometerData(from: startOfYesterday, to: startOfToday) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            self?.yesterdaySteps = pedometerData.numberOfSteps.intValue
            DispatchQueue.main.async {
                self?.yesterdayStepsLabel.text = pedometerData.numberOfSteps.stringValue
                self?.updateGoalProgress()
            }
        }
        self.pedometer.queryPedometerData(from: startOfToday, to: dateNow) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            self?.todaySteps = pedometerData.numberOfSteps.intValue
            DispatchQueue.main.async {
                self?.todayStepsLabel.text = pedometerData.numberOfSteps.stringValue
            }
        }
    }
    
    private func startCountingSteps() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.startUpdates(from: Date()) {
            [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else { return }
            DispatchQueue.main.async {
                let todaySteps = self?.todaySteps ?? 0
                self?.todayStepsLabel.text = String(todaySteps + pedometerData.numberOfSteps.intValue)
                self?.notification.notificationOccurred(.success)
            }
        }
    }
    
    private func startTrackingCurrentActivity() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        activityManager.startActivityUpdates(to: OperationQueue.main) {
            [weak self] (activity: CMMotionActivity?) in
            
            guard let activity = activity else {
                return
            }
            DispatchQueue.main.async {
                self?.currentActivityLabel.fadeTransition(0.6)
                if activity.walking {
                    self?.currentActivityLabel.text = "🚶‍ Walking"
                } else if activity.stationary {
                    self?.currentActivityLabel.text = "🛑 Stationary"
                } else if activity.running {
                    self?.currentActivityLabel.text = "🏃‍ Running"
                } else if activity.cycling {
                    self?.currentActivityLabel.text = "🚴‍ Cycling"
                } else if activity.automotive {
                    self?.currentActivityLabel.text = "🚗 Automotive"
                } else {
                    self?.currentActivityLabel.text = "❓ Unknown"
                }
            }
        }
    }
    
    private func updateGoalProgress() {
        let yesterdaySteps = self.yesterdaySteps
        let stepsGoal = statisticsDataManager.statistics.stepsGoal
        goalProgressLabel.text = "\(yesterdaySteps)/\(stepsGoal)"
        goalProgressBar.setProgress(Float(yesterdaySteps) / Float(stepsGoal), animated: true)
        UserDefaults.standard.set(yesterdaySteps, forKey: "yesterdaySteps")
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "devouredSegue" {
            if yesterdaySteps < statisticsDataManager.statistics.stepsGoal {
                let alert = UIAlertController(title: "Unable to play the Devoured!", message: "Sorry, the steps goal for the previous day not achieved.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return false
            }
        }
        return true
    }
    
}

