//
//  MenuScene.swift
//  ZombieDefence
//
//  Created by Van Osch Benjamin D. on 4/18/19.
//  Copyright © 2019 Van Osch Benjamin D. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var starfield:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView){
       starfield = self.childNode(withName: "starfield") as! SKEmitterNode
       starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        
        difficultyButtonNode.texture = SKTexture(imageNamed: "difficultyButton")
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        //maybe self.view
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
        
    }
}
