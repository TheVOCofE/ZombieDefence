//
//  GameOverScene.swift
//  ZombieDefence
//
//  Created by Van Osch Benjamin D. on 4/23/19.
//  Copyright © 2019 Van Osch Benjamin D. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    var score:Int = 0
    
    var scoreLabel:SKLabelNode!
    var newGameButtonNode:SKSpriteNode!
    var scrollingBackground:SKEmitterNode!
    
    override func didMove(to view: SKView) {
        //get nodes from scene
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "NewGameButton")
        scrollingBackground = self.childNode(withName: "scrollingBackground") as! SKEmitterNode
        scrollingBackground.advanceSimulationTime(10)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let newSize = CGSize(width: 750, height: 1334);
                let gameScene = GameScene(size: newSize)
                self.view!.presentScene(gameScene, transition: transition)
            }
        }
    }
}
