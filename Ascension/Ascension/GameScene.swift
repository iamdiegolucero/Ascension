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
    
    var hero: Hero!
    
    override func didMove(to view: SKView) {
        self.childNode(withName: "hero") as!Hero
    }
    
}
