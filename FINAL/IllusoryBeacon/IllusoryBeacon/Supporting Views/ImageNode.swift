//
//  ImageNode.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class ImageNode: SCNNode {
    
    static let hardcodedFrameWidth: CGFloat = 0.045

    var image: UIImage?
    let width: CGFloat = 0.3
    let height: CGFloat = 0.3
    
    var imageNode: SCNNode?
    var frameNode: SCNNode?
    
    override init() {
        super.init()
        name = "image_node"
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        name = "image_node"
        setup()
    }
    
    func setup() {
        geometry = SCNPlane(width: width, height: height)
    }
    
    func setup(image: UIImage) {
        (imageNode?.geometry as? SCNPlane)?.width = width - ImageNode.hardcodedFrameWidth
        (imageNode?.geometry as? SCNPlane)?.height = height - ImageNode.hardcodedFrameWidth
        frameNode?.removeFromParentNode()
        frameNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        frameNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "frame")!
        frameNode?.name = "frame"
        addChildNode(frameNode!)
        
        self.image = image
        let resizedImage = image.resize(targetSize: CGSize(width: 1280, height: 720)).cropToSquare()
        geometry?.firstMaterial?.isDoubleSided = true
        
        imageNode?.removeFromParentNode()
        imageNode = SCNNode(geometry: SCNPlane(width: width - ImageNode.hardcodedFrameWidth, height: height - ImageNode.hardcodedFrameWidth))
        imageNode?.geometry?.firstMaterial?.diffuse.contents = resizedImage
        imageNode?.geometry?.firstMaterial?.readsFromDepthBuffer = false
        imageNode?.position.z += 0.001
        imageNode?.renderingOrder = 2
        imageNode?.name = "image"
        
        addChildNode(imageNode!)
    }
}
