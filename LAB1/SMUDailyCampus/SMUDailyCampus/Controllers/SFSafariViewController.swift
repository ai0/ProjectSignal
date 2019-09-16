//
//  SFSafariViewController.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SafariServices

extension SFSafariViewController {
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00)
    }
    
}
