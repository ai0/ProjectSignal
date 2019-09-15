//
//  NewsCell.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import SwifterSwift

class NewsCell: UICollectionViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var excerpt: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        borderWidth = 3
        borderColor = UIColor.FlatUI.asbestos
    }
}
