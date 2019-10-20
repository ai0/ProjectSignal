//
//  DevouredViewController.swift
//  Devoured
//
//  Created by Jing Su on 10/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class DevouredViewController: UIViewController {
    
    private var scene: DevouredScene?
    private let statisticsDataManager: StatisticsDataManager = .shared
    private var gameStarted = false
    
    @IBOutlet weak var titleLabel: GlitchLabel!
    @IBOutlet weak var instructionText: UITextView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var playDevouredBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        livesLabel.text = "Lives: \(statisticsDataManager.statistics.currentLives)"
        scoreLabel.isHidden = true
        checkLives()

        if let view = self.view as! SKView? {
            scene = DevouredScene(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            scene!.scaleMode = .resizeFill
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(gameOver),
            name: .gameOver,
            object: nil
        )
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func checkLives() {
        if (statisticsDataManager.statistics.currentLives <= 0) {
            playDevouredBtn.setImage(UIImage.init(named: "return"), for: .normal)
            playDevouredBtn.setTitle("Return", for: .normal)
        } else {
            playDevouredBtn.setImage(UIImage.init(named: "gamepad"), for: .normal)
            playDevouredBtn.setTitle("Play", for: .normal)
        }
    }
    
    func setElementsHiddenStatus(to targetHiddenStatus: Bool) {
        for element in [titleLabel, instructionText, scoreLabel, livesLabel, playDevouredBtn] {
            element?.isHidden = targetHiddenStatus
        }
    }
    
    func startGame() {
        setElementsHiddenStatus(to: true)
        scene?.startGame()
        gameStarted = true
    }
    
    @objc func gameOver(_ notification: Notification) {
        if gameStarted {
            gameStarted = false
            
            let score = notification.object as! Int
            if (score > statisticsDataManager.statistics.highestScore) {
                statisticsDataManager.statistics.highestScore = score
            }
            statisticsDataManager.statistics.currentLives -= 1
            statisticsDataManager.statistics.gameTriedCount += 1
            statisticsDataManager.save()
            checkLives()
            
            scoreLabel.text = "Score: \(score)"
            livesLabel.text = "Lives: \(statisticsDataManager.statistics.currentLives)"
            
            setElementsHiddenStatus(to: false)
        }
    }
    
    @IBAction func playDevoured(_ sender: UIButton) {
        if (statisticsDataManager.statistics.currentLives <= 0) {
            self.dismiss(animated: true, completion: nil)
        } else {
            startGame()
        }
    }
    
}

