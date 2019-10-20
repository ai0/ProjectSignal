//
//  DevouredScene.swift
//  Devoured
//
//  Created by Jing Su on 10/14/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SpriteKit
import CoreMotion

class DevouredScene: SKScene, SKPhysicsContactDelegate {
    
    private let PlanetCategory: UInt32 = 0x1 << 0
    private let HoleCategory: UInt32 = 0x1 << 1
    private let BorderCategory: UInt32 = 0x1 << 2
    private let MeteorCategory: UInt32 = 0x1 << 3
    private let motion = CMMotionManager()
    private let notification = UINotificationFeedbackGenerator()
    private let workQueue = DispatchQueue(label: "DevouredQueue", attributes: .concurrent)
    private let scoreLabel = SKLabelNode(fontNamed: "Futura")
    
    private var planet = SKSpriteNode(imageNamed: "planet")
    private var hole = SKSpriteNode(imageNamed: "hole")
    private var meteors = Array<SKSpriteNode>()
    private var meteorRushTimer: Timer?
    
    private var score: Int = 0 {
        willSet(newScore) {
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score: \(newScore)"
            }
        }
    }
    
    // MARK: Raw Motion Functions
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 0.1
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
        }
        
    }
    
    // MARK: View Hierarchy Functions
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.black
        
        meteorRushTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            self.workQueue.async {
                DispatchQueue.main.async {
                    self.meteors.append(self.generateMeteor())
                }
            }
        }
    }
    
    func startGame() {
        score = 0
        removeMeteors()

        meteorRushTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) {
            _ in
            self.workQueue.async {
                usleep(UInt32.random(in: 100...2000))
                DispatchQueue.main.async {
                    self.meteors.append(self.generateMeteor())
                }
            }
        }
        
        startMotionUpdates()
        addScoreLabel()
        addHole()
        addPlanet()
        addPeripheries()
    }
    
    func nextRound() {
        hole.removeFromParent()
        score += 1
        addHole()
    }
    
    func gameOver() {
        NotificationCenter.default.post(name: .gameOver, object: score)
        hole.removeFromParent()
        planet.removeFromParent()
        scoreLabel.removeFromParent()
    }
    
    func removeMeteors() {
        meteorRushTimer?.invalidate()
        for meteor in meteors {
            meteor.removeFromParent()
        }
        meteors.removeAll()
    }
    
    // MARK: Create Sprites Functions
    
    func addScoreLabel() {
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = UIColor.systemIndigo
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: frame.minX + scoreLabel.fontSize, y: frame.minY + scoreLabel.fontSize)
        scoreLabel.text = "Score: \(score)"
        self.addChild(scoreLabel)
    }
    
    func addPlanet() {
        planet.name = "planet"
        planet.size = CGSize(width: size.height * 0.042, height: size.height * 0.042)
        
        let randNumber = CGFloat.random(in: 0.25 ..< 0.75)
        planet.position = CGPoint(x: size.width * randNumber, y: size.height * randNumber)
        
        planet.physicsBody = SKPhysicsBody(rectangleOf: planet.size)
        planet.physicsBody?.restitution = CGFloat(0.1)
        planet.physicsBody?.isDynamic = true
        planet.physicsBody?.contactTestBitMask = 0x00000001
        planet.physicsBody?.collisionBitMask = PlanetCategory
        planet.physicsBody?.categoryBitMask = 0x00000001
        planet.physicsBody?.linearDamping = 1
        planet.physicsBody?.allowsRotation = false
        
        self.addChild(planet)
    }
    
    func addHole() {
        hole.name = "hole"
        hole.size = CGSize(width: size.height * 0.048, height: size.height * 0.048)
        
        let randNumber = CGFloat.random(in: 0.1 ..< 0.9)
        hole.position = CGPoint(x: size.width * randNumber, y: size.height * randNumber)
        
        hole.physicsBody = SKPhysicsBody(rectangleOf: hole.size)
        hole.physicsBody?.restitution = CGFloat(0.1)
        hole.physicsBody?.isDynamic = false
        hole.physicsBody?.contactTestBitMask = 0x00000001
        hole.physicsBody?.collisionBitMask = HoleCategory
        hole.physicsBody?.categoryBitMask = 0x00000001
        hole.physicsBody?.linearDamping = 1
        hole.physicsBody?.allowsRotation = false
        
        self.addChild(hole)
    }
    
    func generateMeteor() -> SKSpriteNode {
        let meteor = SKSpriteNode(imageNamed: "meteor")
        
        var randNumber = CGFloat.random(in: 0.032 ..< 0.064)
        meteor.size = CGSize(width: size.height * randNumber, height: size.height * randNumber)
        
        randNumber = CGFloat.random(in: 0.1 ..< 0.9)
        let randX = [0, 1].randomElement()!
        meteor.position = CGPoint(x: size.width * CGFloat(randX), y: size.height * randNumber)
        
        meteor.physicsBody = SKPhysicsBody(rectangleOf: meteor.size)
        meteor.physicsBody?.isDynamic = false
        meteor.physicsBody?.contactTestBitMask = 0x00000000
        meteor.physicsBody?.collisionBitMask = MeteorCategory
        meteor.physicsBody?.categoryBitMask = 0x00000001
        
        if randX == 1 {
            meteor.zRotation = .pi
            meteor.run(SKAction.moveTo(x: 0 - meteor.size.width,
                                       duration: Double.random(in: 8 ..< 16)),
                       completion: {() -> Void in meteor.removeFromParent()})
        } else {
            meteor.run(SKAction.moveTo(x: self.size.width,
                                       duration: Double.random(in: 8 ..< 16)),
                       completion: {() -> Void in meteor.removeFromParent()})
        }
        self.addChild(meteor)
        return meteor
    }
    
    func addPeripheries(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bottom = SKSpriteNode()
        
        left.name = "leftBound"
        left.size = CGSize(width:size.width*0.001, height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.name = "rightBound"
        right.size = CGSize(width:size.width*0.001, height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.name = "topBound"
        top.size = CGSize(width:size.width, height:size.height*0.001)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bottom.name = "bottomBound"
        bottom.size = CGSize(width:size.width, height:size.height*0.001)
        bottom.position = CGPoint(x:size.width*0.5, y:0)
        
        for obj in [left, right, top, bottom]{
            obj.color = UIColor.black
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            obj.physicsBody?.collisionBitMask = BorderCategory
            self.addChild(obj)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.collisionBitMask < contact.bodyB.collisionBitMask {
          firstBody = contact.bodyA
          secondBody = contact.bodyB
        } else {
          firstBody = contact.bodyB
          secondBody = contact.bodyA
        }
        if firstBody.collisionBitMask == PlanetCategory {
            if secondBody.collisionBitMask == BorderCategory || secondBody.collisionBitMask == MeteorCategory {
                notification.notificationOccurred(.error)
                self.gameOver()
            } else if secondBody.collisionBitMask == HoleCategory {
                notification.notificationOccurred(.success)
                nextRound()
            }
        }
    }
    
}

