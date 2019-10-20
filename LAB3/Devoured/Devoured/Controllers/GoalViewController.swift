//
//  GoalViewController.swift
//  Devoured
//
//  Created by Jing Su on 10/13/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class GoalViewController: UITableViewController {
    
    private let statisticsDataManager: StatisticsDataManager = .shared
    private var yesterdaySteps = 0

    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var stepsGoalSlider: UISlider!
    @IBOutlet weak var highestScoreLabel: UILabel!
    @IBOutlet weak var gameTriedLabel: UILabel!
    @IBOutlet weak var currentLivesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadStatistics()
        yesterdaySteps = UserDefaults.standard.integer(forKey: "yesterdaySteps")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private func loadStatistics() {
        stepsGoalLabel.text = String(statisticsDataManager.statistics.stepsGoal)
        stepsGoalSlider.setValue(Float(statisticsDataManager.statistics.stepsGoal), animated: true)
        highestScoreLabel.text = String(statisticsDataManager.statistics.highestScore)
        gameTriedLabel.text = String(statisticsDataManager.statistics.gameTriedCount)
        currentLivesLabel.text = String(statisticsDataManager.statistics.currentLives)
    }
    
    @IBAction func stepsGoalIsChanged(_ sender: UISlider) {
        let newStepsGoal = Int(sender.value)
        stepsGoalLabel.text = String(newStepsGoal)
        statisticsDataManager.statistics.stepsGoal = newStepsGoal
        statisticsDataManager.save()
    }
    
    @IBAction func exchangeLife(_ sender: UIButton) {
        let currentTimestamp = Int(NSDate().timeIntervalSince1970)
        let intervalBetweenLastExchange = currentTimestamp - statisticsDataManager.statistics.lastExchangeLifeTimestamp
        // 86400s = 24h, only allow exchange once per day
        if (intervalBetweenLastExchange > 86400) {
            let livesBonus = Int(yesterdaySteps / 1000)
            statisticsDataManager.statistics.currentLives += livesBonus
            statisticsDataManager.statistics.lastExchangeLifeTimestamp = currentTimestamp
            statisticsDataManager.save()
            loadStatistics()
            let alert = UIAlertController(title: "Exchange life completed!", message: "Congrats! You earned \(livesBonus) lives from yesterday's steps. (1000 steps = 1 life)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            let waitHours = (86400 - intervalBetweenLastExchange) / 3600
            let alert = UIAlertController(title: "Exchange life cooldown!", message: "Sorry, exchange life is currently cooldown, please come by \(waitHours) hours later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func resetStatistics(_ sender: UIButton) {
        statisticsDataManager.reset()
        loadStatistics()
    }
    
}

