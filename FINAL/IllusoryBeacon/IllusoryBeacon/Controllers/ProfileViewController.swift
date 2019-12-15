//
//  ProfileViewController.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

class ProfileViewController: UIHostingController<ProfileView> {
    
    private let userClient: UserClient = .shared
    private var userStatus: UserStatusObservable = UserStatusObservable()
    
    required init?(coder: NSCoder) {
        super.init(
            coder: coder,
            rootView: ProfileView(userStatus: userStatus)
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !userClient.isLogged || !userClient.checkin() {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }!
            window.rootViewController = UIHostingController(
                rootView: WelcomePageView()
            )
            UIView.transition(with: window, duration: 2.0, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        } else {
            if let latestUserStatus = userClient.updateStatus() {
                userStatus.update(userStatus: latestUserStatus)
            }
        }
    }

}

