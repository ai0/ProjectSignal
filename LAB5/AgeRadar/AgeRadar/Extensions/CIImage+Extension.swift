//
//  CIImage+Extension.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit

public extension CIImage {

    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        let uiImage = UIImage(ciImage: self)
        return uiImage.jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func jpeg(_ jpegQuality: Float) -> Data? {
        let uiImage = UIImage(ciImage: self)
        return uiImage.jpegData(compressionQuality: CGFloat(jpegQuality))
    }

}
