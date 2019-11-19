//
//  VideoAnalgesic+Extension.swift
//  AgeRadar
//
//  Created by Jing Su on 11/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import UIKit
import AVFoundation

extension VideoAnalgesic {

    func getSnapshot() -> UIImage {
        let snapshot = videoPreviewView.snapshot
        let orientation = UIDevice.current.orientation.cameraOrientation()
        return UIImage(cgImage: snapshot.cgImage!, scale: snapshot.scale, orientation: orientation)
    }

}
