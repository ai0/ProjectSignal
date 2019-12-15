//
//  UserStatus.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

class UserStatus{
    var email: String
    var nickname: String
    var avatar: UIImage
    var postTexts: Int
    var postImages: Int
    
    init(email: String, nickname: String, avatar: UIImage, postTexts: Int, postImages: Int) {
        self.email = email
        self.nickname = nickname
        self.avatar = avatar
        self.postTexts = postTexts
        self.postImages = postImages
    }
}
