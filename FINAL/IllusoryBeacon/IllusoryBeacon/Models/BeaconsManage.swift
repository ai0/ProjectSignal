//
//  BeaconsManage.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import ARKit

class BeaconsManage {
    var scene: SCNScene

    var lastPosition: SCNVector3 = SCNVector3(-1.2, 0.1, -0.5)
    var rowItems: Int = 0
    var nodePosition: SCNVector3 {
        if rowItems >= 3 {
            lastPosition.x = -0.8
            lastPosition.y -= 0.2
            rowItems = 1
        } else {
            lastPosition.x += 0.4
            rowItems += 1
        }
        return lastPosition
    }
    
    init(scene: SCNScene) {
        self.scene = scene
    }
    
    func clearNodes() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
        }
        self.lastPosition.x = -1.2
        self.lastPosition.y = 0.1
        self.rowItems = 0
    }
    
    func addTextNode(verbatim: String) {
        DispatchQueue.global(qos: .userInteractive).async {
            let text = SCNText(string: verbatim.prefix(16), extrusionDepth: 1)
            
            text.firstMaterial?.diffuse.contents = UIColor.IllusoryBeacon.primary
            text.firstMaterial?.lightingModel = .lambert
            text.firstMaterial?.isDoubleSided = true
            text.font = UIFont(name: "HelveticaNeue-UltraLight", size: 48)
            text.flatness = 0
            text.isWrapped = true

            DispatchQueue.main.async {
                let textNode = SCNNode(geometry: text)
                textNode.name = "text"
                textNode.position = self.nodePosition
                textNode.scale = SCNVector3(0.001, 0.001, 0.001)
                textNode.eulerAngles.y = 0
                textNode.castsShadow = true
                self.scene.rootNode.addChildNode(textNode)
            }

        }
    }
    
    func addImageNode(image: UIImage) {
        DispatchQueue.global(qos: .userInteractive).async {
            let imageNode = ImageNode()
            imageNode.setup(image: image)

            DispatchQueue.main.async {
                imageNode.position = self.nodePosition
                imageNode.scale = SCNVector3(0.5, 0.5, 0.5)
                self.scene.rootNode.addChildNode(imageNode)
            }
        }
    }
    
}
