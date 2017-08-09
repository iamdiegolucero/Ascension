//
//  TutorialScene.swift
//  Ascension
//
//  Created by Diego Lucero on 8/4/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum tutorialState {
    case welcome, swipe, jump
}

class TutorialScene: SKScene, SKPhysicsContactDelegate {
    var hero: SKSpriteNode!
    var moveDirection: CGFloat = 2.8
    var gameState: GameSceneState = .tutorial
    var jump: jumpTest = .ground
    
    override func didMove(to view: SKView) {
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        //Setup your scene here
        
        hero = self.childNode(withName: "hero") as! SKSpriteNode
        
        
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
        //        print("swiped right")
        //hero.physicsBody?.velocity.dx = 200
        moveDirection = 2.7
        
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        //        print("swiped left")
        //hero.physicsBody?.velocity.dx = -200
        moveDirection = -2.7
        
        
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        //        print("swiped up")
        if gameState == .tutorial {
            
            let velocityY = hero.physicsBody?.velocity.dy ?? 0
            
            if jump == .jump || jump == .ground {
                hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20 + abs(velocityY)))
            }
            
            if jump == .ground {
                jump = .jump
            }
            else {
                jump = .doubleJump
            }
        }
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        //        print("swiped down")
    }
    
    override func update(_ currentTime: TimeInterval) {
        hero.position.x += moveDirection
        if hero.position.x < -150 {
            hero.position.x = 150
        }
        
        if hero.position.x > 150 {
            hero.position.x = -150
        }
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        
        /* Check and cap vertical velocity */
        if velocityY > 500 {
            hero.physicsBody?.velocity.dy = 500
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB

        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
            jump = .ground
        }
    }
}
