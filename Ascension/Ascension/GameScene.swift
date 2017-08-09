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
    case active, gameOver, menu, pause, tutorial
}

enum jumpTest {
    case ground, jump, doubleJump
}

enum gameOverText {
    case moveTip, jumpTip, dodgeTip
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var tap: UITapGestureRecognizer!
    var hero: SKSpriteNode!
    var fireball: SKSpriteNode!
    var platformSource: SKNode!
    var platformLayer: SKNode!
    var startPlatform: SKNode!
    var fireballLayer: SKNode!
    var scoreLabel: SKLabelNode!
    var highscoreLabel: SKLabelNode!
    var tips: SKLabelNode!
    var title: SKSpriteNode!
    let scrollSpeed: CGFloat = 100
    var spawnTimer: CFTimeInterval = 0
    var fireballSpawnTimer: CFTimeInterval = 0
    var points: Int = 0
    var hs = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var go = false
    var gameState: GameSceneState = .menu
    var jump: jumpTest = .ground
    var moveDirection: CGFloat = 2.7
    /* UI Connections */
    var playButton: MSButtonNode!
    var buttonRestart: MSButtonNode!
    var pauseButton: SKSpriteNode!
    var resumeButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        //Setup your scene here
        
        hero = self.childNode(withName: "hero") as! SKSpriteNode
        
        // Fireball
        /* Set reference to obstacle Source node */
        platformSource = self.childNode(withName: "platform")
        /* Set reference to obstacle layer node */
        platformLayer = self.childNode(withName: "platformLayer")
        fireballLayer = self.childNode(withName: "fireballLayer")
        startPlatform = self.childNode(withName: "startPlatform")
        /* Set UI connections */
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode
        resumeButton = self.childNode(withName: "resumeButton") as! SKSpriteNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        highscoreLabel = self.childNode(withName: "highscoreLabel") as! SKLabelNode
        tips = self.childNode(withName: "tips") as! SKLabelNode
        title = self.childNode(withName: "title") as! SKSpriteNode
        fireball = self.childNode(withName: "fireball") as! SKSpriteNode
        /* Setup restart button selection handler */
        self.buttonRestart.state = .MSButtonNodeStateHidden
        self.pauseButton.isHidden = true
        self.resumeButton.isHidden = true
        self.tips.isHidden = true
        let restoredHS = UserDefaults.standard.value(forKey: "hs") as? NSInteger
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        // print("\n\nHighScore Restored: ", restoredHS!/60)
        if let temp = restoredHS {
            hs = temp
        }
        highscoreLabel.text = String(Int(hs/60))
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
            self.startGame()
            if randomZeroToOne() > 0.5 {
                self.moveDirection = 2.7
            }
            else {
                self.moveDirection = -2.7
            }
            self.playButton.state = .MSButtonNodeStateHidden
            self.pauseButton.isHidden = false
        }
        
//        pauseButton.selectedHandler = {
//            if self.gameState == .active {
//                self.resumeButton.state = .MSButtonNodeStateActive
//            }
//            self.gameState = .pause
//        }
        
//        resumeButton.selectedHandler = {
//            if self.gameState != .gameOver {
//                self.gameState = .active
////                self.pauseButton.state = .MSButtonNodeStateActive
//            }
//        }
        
//        tutorialButton.selectedHandler = {
//            let skView = self.view as SKView!
//            
//            /* Load Game scene */
//            let scene = TutorialScene(fileNamed:"Tutorial") as TutorialScene!
//            
//            /* Ensure correct aspect mode */
//            scene?.scaleMode = .aspectFill
//            
//            /* Restart game scene */
//            skView?.presentScene(scene)
//            self.gameState = .tutorial
//
//        }
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        
//        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
//        swipeUp.direction = .up
//        view.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        scoreLabel.text = "\(points)"
    }
    
    func tapped(sender:UITapGestureRecognizer){
        if gameState == .active  {
            
            let velocityY = hero.physicsBody?.velocity.dy ?? 0
            
            if jump == .jump || jump == .ground {
                hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 22 + abs(velocityY)))
            }
            
            if jump == .ground {
                jump = .jump
            }
            else {
                jump = .doubleJump
            }
        }
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
    
//    func swipedUp(sender:UISwipeGestureRecognizer){
//        //        print("swiped up")
//        if gameState == .active  {
//            
//            let velocityY = hero.physicsBody?.velocity.dy ?? 0
//            
//            if jump == .jump || jump == .ground {
//                hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20 + abs(velocityY)))
//            }
//            
//            if jump == .ground {
//                jump = .jump
//            }
//            else {
//                jump = .doubleJump
//            }
//        }
//    }
//    
    func swipedDown(sender:UISwipeGestureRecognizer){
        //        print("swiped down")
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState == .menu {
            let scrollRight = SKAction(named: "scrollRight")
            let scrollUp = SKAction(named: "scrollUp")
            let tutorialButtonMove = SKAction(named: "tutorialButtonMove")
            title.run(scrollUp!)
            self.playButton.state = .MSButtonNodeStateActive
            //playButton.run(scrollRight!)
//            self.tutorialButton.state = .MSButtonNodeStateActive
//            tutorialButton.run(tutorialButtonMove!)
        }
        else{
            title.alpha = 0
            self.playButton.state = .MSButtonNodeStateHidden
        }
        if gameState == .active {
            hero.position.x += moveDirection
            self.resumeButton.isHidden = true
        }
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        
//         Check and cap vertical velocity 
        if velocityY > 500 {
            hero.physicsBody?.velocity.dy = 500
        }
        
        if hero.position.x < -150 {
            hero.position.x = 150
        }
        
        if hero.position.x > 150 {
            hero.position.x = -150
        }
        animationTest()
        /* Process obstacles */
        if gameState == .active {
            updateObstacles()
            fireBallSpawner()
            points += 1
            spawnTimer += fixedDelta
            fireballSpawnTimer += fixedDelta
            scoreLabel.text = String(points/60)
        }
        
        //Set highscore
        if points > hs {
            hs = points
            highscoreLabel.text = String(points/60)
            var HighscoreDefault = UserDefaults.standard
            HighscoreDefault.setValue(hs, forKey: "hs")
            HighscoreDefault.synchronize()
        }
        
        
        
        if gameState == .pause || gameState == .gameOver {
            //self.pauseButton.state = .MSButtonNodeStateHidden
        }
    }
    
    func startGame() {
        view!.addGestureRecognizer(self.tap)
        print("added tap")
    }
    
    func updateObstacles() {
        if gameState == .active {
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
            if spawnTimer >= 1.8 {
                
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
//        let nodeA = contactA.node as! SKSpriteNode
//        let nodeB = contactB.node as! SKSpriteNode
        /* Check if either physics bodies was lava */
        if (contactA.categoryBitMask == 4 && contactB.categoryBitMask == 1) || (contactB.categoryBitMask == 4 && contactA.categoryBitMask == 1) {
            runGameOver()

        }
        if contactA.categoryBitMask == 8 || contactB.categoryBitMask == 8 {
            jump = .ground
        }

        if (contactA.categoryBitMask == 16 && contactB.categoryBitMask == 1) || (contactB.categoryBitMask == 16 && contactA.categoryBitMask == 1) {
          runGameOver()
        }
    }
    
    func runGameOver() {
        gameState = .gameOver
        if view?.gestureRecognizers! != nil {
            view?.removeGestureRecognizer(self.tap)
            print("removed tapped")
        }
        tipText()
        UserDefaults.standard.setValue(hs, forKey: "hs")
        buttonRestart.state = .MSButtonNodeStateActive
        resumeButton.isHidden = true
        pauseButton.isHidden = true
        //pauseButton.state = .MSButtonNodeStateHidden
    }
    
    func fireBallSpawner() {
        if gameState == .active {
            // fireball.position.y += scrollSpeed * CGFloat(fixedDelta)
            for fireball in fireballLayer.children as! [SKSpriteNode] {
                let fireballPosition = fireballLayer.convert(fireball.position, to: self)
                if fireballPosition.y > 316 {
                    
                    fireball.removeFromParent()
                }
            }
            if points > 60*15 {
                fireballLayer.position.y += scrollSpeed * CGFloat(fixedDelta) * 1.2
                if fireballSpawnTimer > 3.5 {
                    let newFireball = fireball.copy() as! SKSpriteNode
                    fireballLayer.addChild(newFireball)
                    let randomPosition = CGPoint(x: CGFloat.random(min: -145, max: 145), y: -299)
                    newFireball.position = self.convert(randomPosition, to:fireballLayer)
                    print(fireballLayer.position)
                    fireballSpawnTimer = 0
                }
            }
        }
    }
    func tipText() {
        tips.isHidden = false
        if randomZeroToOne() < 0.25 {
            tips.text = "Tip: Tap to jump."
            return
        }
        else {
            if randomZeroToOne() < 0.25 {
                tips.text = "Tip: To double jump, double tap."
                return
            }
            else{
                if randomZeroToOne() < 0.25 {
                    tips.text = "Tip: Change direction constantly."
                    return
                }
                else {
                    tips.text = "Tip: Swipe to change direction."
                    return
                }
            }
        }
    }
    func animationTest() {
        if gameState != .active {
            hero.removeAllActions()
            fireball.removeAllActions()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            if pauseButton.contains(t.location(in: self)) {
                if self.gameState == .active {
                    self.resumeButton.isHidden = false
                }
                if gameState == .active {
                self.gameState = .pause
                pauseButton.isHidden = true
                }
            }
            if resumeButton.contains(t.location(in: self)) {
                if self.gameState != .gameOver {
                    self.gameState = .active
                    self.pauseButton.isHidden = false
                }
            }
        }
    }
}

