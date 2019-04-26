//
//  MenuScene.swift
//  ZombieDefence
//
//  Created by Van Osch Benjamin D. on 4/18/19.
//  Copyright © 2019 Van Osch Benjamin D. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    var scrollingBackground:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView){
       scrollingBackground = self.childNode(withName: "scrollingBackground") as! SKEmitterNode
       scrollingBackground.advanceSimulationTime(30)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hard"){
            difficultyLabelNode.text = "Hard"
        }else{
            difficultyLabelNode.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        let touch = touches.first
        //maybe self.view
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton"{
                  //print("touch.location(in: self.view)")
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let newSize = CGSize(width: 750, height: 1334);
                let gameScene = GameScene(size: newSize)
                self.view?.presentScene(gameScene, transition: transition)
            }
            else if nodesArray.first?.name == "difficultyButton"
            {
                changeDifficulty()
            }
        }
    }
    
    
    func changeDifficulty(){
        let userDefaults = UserDefaults.standard
        
        if difficultyLabelNode.text == "Easy"{
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        }else{
            difficultyLabelNode.text = "Easy"
            userDefaults.set((false), forKey: "hard")
        }
        userDefaults.synchronize()
    }
}
