//
//  UserStatusObservable.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Combine
import SwiftUI

final class UserStatusObservable: ObservableObject {

    @Published var email: String = ""
    @Published var nickname: String = ""
    @Published var avatar: UIImage = UIImage(named: "icon")!
    @Published var postTexts: Int = 0
    @Published var postImages: Int = 0
    
    func update(email: String, nickname: String, avatar: UIImage, postTexts: Int, postImages: Int) {
        self.email = email
        self.nickname = nickname
        self.avatar = avatar
        self.postTexts = postTexts
        self.postImages = postImages
    }
    
    func update(userStatus: UserStatus) {
        self.email = userStatus.email
        self.nickname = userStatus.nickname
        self.avatar = userStatus.avatar
        self.postTexts = userStatus.postTexts
        self.postImages = userStatus.postImages
    }

}
