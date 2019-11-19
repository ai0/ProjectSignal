//
//  SettingsViewController.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    private let mlServiceClient: MLServiceClient = .shared
    private let settingsManage: SettingsManage = .shared

    @IBOutlet weak var currentUserLabel: UILabel!
    @IBOutlet weak var imageQualitySegCtrl: UISegmentedControl!
    @IBOutlet weak var mlAlgorithmSegCtrl: UISegmentedControl!
    @IBOutlet weak var kNNNeighborsSlider: UISlider!
    @IBOutlet weak var KNNNeighborsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mlServiceClient.signedUser == nil {
            presentAuthentication()
        } else {
            updateUserNameLabel()
        }
    }

    @IBAction func logout(_ sender: UIButton) {
        mlServiceClient.logout()
        settingsManage.clearUser()
        presentAuthentication()
    }
    
    @IBAction func imageQualityIsChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            settingsManage.settings.imageQuality = 0.75
        } else if sender.selectedSegmentIndex == 1 {
            settingsManage.settings.imageQuality = 0.5
        } else {
            settingsManage.settings.imageQuality = 0.25
        }
        settingsManage.save()
    }
    
    @IBAction func modelAlgorithmIsChanged(_ sender: UISegmentedControl) {
        settingsManage.settings.mlAlgorithm = sender.selectedSegmentIndex == 0 ? "KNN" : "SVM"
        settingsManage.save()
    }
    
    @IBAction func kNNNeighborsIsChanged(_ sender: UISlider) {
        let neighbors = Int(sender.value)
        KNNNeighborsLabel.text = String(neighbors)
        settingsManage.settings.kNNNeighbors = neighbors
        settingsManage.save()
    }
    
    @IBAction func updateModel(_ sender: UIButton) {
        let algorithm = settingsManage.settings.mlAlgorithm
        let neighbors = settingsManage.settings.kNNNeighbors
        let result = algorithm == "KNN" ? mlServiceClient.updateModel(algorithm: algorithm, kNNneighbors: neighbors) : mlServiceClient.updateModel(algorithm: algorithm, kNNneighbors: nil)
        var alert: UIAlertController
        if result {
            alert = UIAlertController(title: "Update Successed", message: "Model updated.", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Update Failed", message: "Failed to update the model.", preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func loadSettings() {
        imageQualitySegCtrl.selectedSegmentIndex = [0.75, 0.5, 0.25].firstIndex(of: settingsManage.settings.imageQuality) ?? 0
        mlAlgorithmSegCtrl.selectedSegmentIndex = settingsManage.settings.mlAlgorithm == "KNN" ? 0 : 1
        kNNNeighborsSlider.value = Float(settingsManage.settings.kNNNeighbors)
        KNNNeighborsLabel.text = String(settingsManage.settings.kNNNeighbors)
    }
    
    func updateUserNameLabel() {
        DispatchQueue.main.async { [weak self] in
            self?.currentUserLabel.text = self?.mlServiceClient.signedUser ?? "Anonymous"
        }
    }
    
    func presentAuthentication() {
        if let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "authModal") {
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = .fullScreen;
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.9)
            present(presentedViewController, animated: true, completion: {
                self.updateUserNameLabel()
            })
        }
    }
    
}

