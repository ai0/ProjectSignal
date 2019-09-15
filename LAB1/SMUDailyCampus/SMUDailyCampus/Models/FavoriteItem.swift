//
//  FavoriteItem.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation

class FavoriteItem: NSObject, NSCoding {

    let title: String
    let link: String
    
    init(title: String, link: String) {
        self.title = title
        self.link = link
    }

    required init(coder decoder: NSCoder) {
        self.title = decoder.decodeObject(forKey: "title") as? String ?? ""
        self.link = decoder.decodeObject(forKey: "link") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(link, forKey: "link")
    }

}
