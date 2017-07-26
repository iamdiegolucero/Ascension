//
//  GameScene.swift
//  Ascension
//
//  Created by Diego Lucero on 7/18/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
    case active, gameOver, menu, pause
}

enum jumpTest {
    case ground, jump, doubleJump
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    var platformSource: SKNode!
    var platformLayer: SKNode!
    var startPlatform: SKNode!
    var scoreLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    var title: SKSpriteNode!
    let scrollSpeed: CGFloat = 80
    var spawnTimer: CFTimeInterval = 0
    var points: Int = 0
    //var highScore: Int = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var go = false
    var pGo = false
    var gameState: GameSceneState = .menu
    var jump: jumpTest = .ground
    var moveDirection: CGFloat = 3.5
    /* UI Connections */
    var playButton: MSButtonNode!
    var buttonRestart: MSButtonNode!
    override func didMove(to view: SKView) {
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Setup your scene here */
        
        hero = self.childNode(withName: "hero") as! SKSpriteNode
        /* Set reference to obstacle Source node */
        platformSource = self.childNode(withName: "platform")
        /* Set reference to obstacle layer node */
        platformLayer = self.childNode(withName: "platformLayer")
        startPlatform = self.childNode(withName: "startPlatform")
        /* Set UI connections */
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        highscoreLabel = self.childNode(withName: "highscoreLabel") as! SKLabelNode
        title = self.childNode(withName: "title") as! SKSpriteNode
        /* Setup restart button selection handler */
        self.buttonRestart.state = .MSButtonNodeStateHidden
        buttonRestart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            self.gameState = .active
            
            /* Hide restart button */
            self.buttonRestart.state = .MSButtonNodeStateHidden
        }
        
        playButton.selectedHandler = {
            
            self.gameState = .active
            self.playButton.state = .MSButtonNodeStateHidden
        }
        
        
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
        scoreLabel.text = "\(points)"
    }
    
    func swipedRight(sender:UISwipeGestureRecognizer){
        print("swiped right")
        pGo = true
        //hero.physicsBody?.velocity.dx = 200
        moveDirection = 3.5
        
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        print("swiped left")
        pGo = true
        //hero.physicsBody?.velocity.dx = -200
        moveDirection = -3.5
        
        
    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        if gameState != .gameOver  {
            
            let velocityY = hero.physicsBody?.velocity.dy ?? 0
            
            if jump == .jump || jump == .ground {
                hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 25 + abs(velocityY)))
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
        print("swiped down")
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == .gameOver {
            return
        }
        if gameState == .menu{
//            let defaults = UserDefaults.standard
//            if let highScore: Int = defaults.value(forKey: "HighScore") as? Int {
//                if points > highScore {
//                    defaults.set(points, forKey: "HighScore")
//                    highscoreLabel.text = String(points/60)
//                }
            }
        
        if gameState == .menu {
            let scrollUp = SKAction(named: "scrollUp")
            title.run(scrollUp!)
            let scrollRight = SKAction(named: "scrollRight")
            self.playButton.state = .MSButtonNodeStateActive
            playButton.run(scrollRight!)
        }
        else{
            title.alpha = 0
            self.playButton.state = .MSButtonNodeStateHidden
        }
        
        if pGo == true{
            hero.position.x += moveDirection
        }
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
        if gameState == .active {
        updateObstacles()
        points += 1
        spawnTimer+=fixedDelta
        scoreLabel.text = String(points/60)
        }
    }
    
    
    
    func updateObstacles() {
        if gameState != .gameOver {
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
            if spawnTimer >= 2.1 {
                
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
            if spawnTimer >= 0.8 {
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 4 || contactB.categoryBitMask == 4 {
            gameState = .gameOver
            buttonRestart.state = .MSButtonNodeStateActive
        }
        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
            jump = .ground
        }
    }
    func randomZeroToOne() -> Double {
        return Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
    }
    
}
