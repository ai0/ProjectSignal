//
//  NewsItem.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/8/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation
import UIKit
import Just

struct NewsItem {
    let title: String!
    let thumbnailURL: String
    let author: String
    let excerpt: String
    let date: Date
    let link: String
    
    var thumbnail: UIImage? {
        let request = Just.get(self.thumbnailURL)
        guard request.ok else {
            return nil
        }
        return UIImage.init(data: request.content!)
    }
    
}
