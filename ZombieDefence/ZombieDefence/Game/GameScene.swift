//
//  GameScene.swift
//  ZombieDefence
//
//  Created by Van Osch Benjamin D. on 4/12/19.
//  Copyright © 2019 Van Osch Benjamin D. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var leftMove:SKSpriteNode!
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleZombies = ["Attack (1).png", "Attack (2).png", "Attack (3).png"]
    
    let zombieCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    var livesArray:[SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        addLives()
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        
        player.position = CGPoint(x: self.anchorPoint.x, y: self.anchorPoint.y-500)
        
        self.addChild(player)
        
        //add movement sprite
        //leftMove = SKSpriteNode(imageNamed: "torpedo")
        
        //leftMove.xScale = 3
        //leftMove.yScale = 3
        //leftMove.position = CGPoint(x: self.anchorPoint.x-30, y: self.anchorPoint.y);
        //leftMove.name = "leftButton"
        //leftMove.isUserInteractionEnabled = false
        //self.addChild(leftMove)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 0, y: anchorPoint.y - 600)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard"){
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addZombie), userInfo: nil, repeats: true)
        
    }
    
    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "shuttle")
            liveNode.position = CGPoint(x: self.anchorPoint.x-200 - CGFloat(4-live)*liveNode.size.width, y: self.anchorPoint.y+600)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    @objc func addZombie () {
        possibleZombies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleZombies) as! [String]
        
        let zombie = SKSpriteNode(imageNamed: possibleZombies[0])
        
        let randomZombiePosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomZombiePosition.nextInt())
        
        zombie.position = CGPoint(x: position, y: self.frame.size.height + zombie.size.height)
        
        zombie.physicsBody = SKPhysicsBody(rectangleOf: zombie.size)
        zombie.physicsBody?.isDynamic = true
        
        zombie.physicsBody?.categoryBitMask = zombieCategory
        zombie.physicsBody?.contactTestBitMask = bulletCategory
        zombie.physicsBody?.collisionBitMask = 0
        
        zombie.xScale = 0.25
        zombie.yScale = 0.25
        
        self.addChild(zombie)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -zombie.size.height), duration: animationDuration))
        actionArray.append(SKAction.run {
            self.run(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
            
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0{
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    //let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    //let gameOverScene = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    let newSize = CGSize(width: 750, height: 1334);
                    let scoretest = self.score
                    let gameOverScene = GameScene(size: newSize)
                    gameOverScene.score = self.score
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            }
        })
        actionArray.append(SKAction.removeFromParent())
        
        zombie.run(SKAction.sequence(actionArray))
        
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let bulletNode = SKSpriteNode(imageNamed: "torpedo")
        bulletNode.position = player.position
        bulletNode.position.y += 5
        
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width / 2)
        bulletNode.physicsBody?.isDynamic = true
        
        bulletNode.physicsBody?.categoryBitMask = bulletCategory
        bulletNode.physicsBody?.contactTestBitMask = zombieCategory
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bulletNode)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        bulletNode.run(SKAction.sequence(actionArray))
        
    }
    
    //override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      //  fireBullet()
    //}
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & zombieCategory) != 0 {
            bulletDidCollideWithZombie(bulletNode: firstBody.node as! SKSpriteNode, zombieNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func bulletDidCollideWithZombie (bulletNode:SKSpriteNode, zombieNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = zombieNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        zombieNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        score += 5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self.view)
        print(touch.location(in: self.view))
        if positionInScene.x < 200
        {
            player.position.x -= 10;
        }
        else if positionInScene.x > 300
        {
             player.position.x += 10;
        }else
        {
            fireBullet()
        }
    }
}
