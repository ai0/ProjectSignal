//
//  String+MD5.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    var md5: String {
        let data = Data(self.utf8)
        return Insecure.MD5.hash(data: data).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
