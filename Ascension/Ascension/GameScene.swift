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
    var moveX: CGFloat = 2
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        

        hero = self.childNode(withName: "hero") as! SKSpriteNode
        moveX = 0
        
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
    }
}
