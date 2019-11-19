//
//  TrainModelViewController.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class TrainModelViewController: UIViewController {
    
    private let mlServiceClient: MLServiceClient = .shared
    private let settingsManage: SettingsManage = .shared
    
    var snapshotImage: UIImage?
    
    @IBOutlet weak var previewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewImage.image = snapshotImage
    }
    
    @IBAction func submitTrainingTask(_ sender: UIButton) {
        var label: String?
        switch sender.tag {
        case 10001:
            // 1-25
            label = "1-25"
        case 10002:
            // 26-50
            label = "26-50"
        case 10003:
            // 51-75
            label = "51-75"
        case 10004:
            // 76+
            label = "76+"
        default:
            break
        }
        guard label != nil, snapshotImage != nil else { return }
        let _ = mlServiceClient.addDataPoint(label: label!, with: snapshotImage!, and: settingsManage.settings.imageQuality)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTraining(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
