//
//  Beacon.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import Just

class Beacon {
    var type: BeaconType
    var text: String?
    var image: UIImage?
    
    enum BeaconType {
        case Text
        case Image
    }
    
    init(type: String, content: String) {
        if type == "image" {
            self.type = .Image
            self.image = getImage(by: content)
        } else {
            self.type = .Text
            self.text = content
        }
    }
    
    func getImage(by imageUUID: String) -> UIImage? {
        struct State {
            static var cache: LRUCache = LRUCache<String>(IMAGE_CACHE_SIZE)
        }
        if let image = State.cache.get(imageUUID) {
            return image as? UIImage
        }
        let imageURL = "\(API_EP)/image/\(imageUUID)"
        let resp = Just.get(imageURL)
        guard resp.ok, resp.statusCode == 200 else {
            return nil
        }
        let image = UIImage(data: resp.content!)
        State.cache.set(imageUUID, val: image!)
        return image
    }
}
