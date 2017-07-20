//
//  GameScene.swift
//  Ascension
//
//  Created by Diego Lucero on 7/18/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var hero: SKSpriteNode!
    var platformSource: SKNode!
    var platformLayer: SKNode!
    var startPlatform: SKNode!
    let scrollSpeed: CGFloat = 80
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var go = false
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        hero = self.childNode(withName: "hero") as! SKSpriteNode
        /* Set reference to obstacle Source node */
        platformSource = self.childNode(withName: "platform")
        /* Set reference to obstacle layer node */
        platformLayer = self.childNode(withName: "platformLayer")
        startPlatform = self.childNode(withName: "startPlatform")
        
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    func swipedRight(sender:UISwipeGestureRecognizer){
        print("swiped right")
        hero.physicsBody?.velocity.dx = 200
        
    }

    func swipedLeft(sender:UISwipeGestureRecognizer){
        print("swiped left")
        hero.physicsBody?.velocity.dx = -200

    
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25))
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        
        /* Check and cap vertical velocity */
        if velocityY > 500 {
            hero.physicsBody?.velocity.dy = 500
        }
        
        if hero.position.x < -150 {
            hero.position.x = 150
        }
        
        if hero.position.x > 150 {
            hero.position.x = -150
        }
        
        /* Process obstacles */
        updateObstacles()
        spawnTimer+=fixedDelta
    }
    
    func updateObstacles() {
        /* Update Obstacles */
        
        platformLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for platform in platformLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let platformPosition = platformLayer.convert(platform.position, to: self)
            
            /* Check if obstacle has left the scene */
            if platformPosition.y <= -240 {
                
                /* Remove obstacle node from obstacle layer */
                platform.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 2 {
            
            /* Create a new obstacle by copying the source obstacle */
            let newPlatform = platformSource.copy() as! SKNode
            platformLayer.addChild(newPlatform)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPoint(x: CGFloat.random(min: -95, max: 95), y: 294)
            
            /* Convert new node position back to obstacle layer space */
            newPlatform.position = self.convert(randomPosition, to: platformLayer)
            
            // Reset spawn timer
            spawnTimer = 0
        }
        if spawnTimer >= 1 {
            go = true
        }
        if go == true {
            startPlatform.position.y -= scrollSpeed * CGFloat(fixedDelta)
        }
            
        if startPlatform.position.y < -240 {
            startPlatform.removeFromParent()
        }
    }
}
