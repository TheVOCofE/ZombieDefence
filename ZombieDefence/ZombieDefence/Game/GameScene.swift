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
    
    var scrollingBackground:SKEmitterNode!
    var player:SKSpriteNode!
    var leftMove:SKSpriteNode!
    var sandbags:SKSpriteNode!
    var sandbags2:SKSpriteNode!
    var sandbags3:SKSpriteNode!
    var sandbags4:SKSpriteNode!
    var sandbags5:SKSpriteNode!
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer:Timer!
    var surTimer:Timer!
    
    var possibleZombies = ["Attack (1).png", "Attack (5).png", "Attack (3).png"]
    
    let zombieCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    let survivorCategory:UInt32 = 0x1 << 2
    
    var livesArray:[SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        addLives()
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        scrollingBackground = SKEmitterNode(fileNamed: "Starfield")
        scrollingBackground.position = CGPoint(x: 0, y: 1472)
        scrollingBackground.advanceSimulationTime(20)
        self.addChild(scrollingBackground)
        
        scrollingBackground.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        
        player.position = CGPoint(x: self.anchorPoint.x, y: self.anchorPoint.y-500)
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 0, y: anchorPoint.y - 600)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        //sandbags
        sandbags = SKSpriteNode(imageNamed: "sandbags")
        sandbags.position = CGPoint(x: -100, y: anchorPoint.y - 400)
        
        self.addChild(sandbags)
        sandbags2 = SKSpriteNode(imageNamed: "sandbags")
        sandbags2.position = CGPoint(x: 0, y: anchorPoint.y - 400)
        
        self.addChild(sandbags2)
        sandbags3 = SKSpriteNode(imageNamed: "sandbags")
        sandbags3.position = CGPoint(x: 100, y: anchorPoint.y - 400)
        
        self.addChild(sandbags3)
        sandbags4 = SKSpriteNode(imageNamed: "sandbags")
        sandbags4.position = CGPoint(x: -200, y: anchorPoint.y - 400)
        
        self.addChild(sandbags4)
        sandbags5 = SKSpriteNode(imageNamed: "sandbags")
        sandbags5.position = CGPoint(x: 200, y: anchorPoint.y - 400)
        
        self.addChild(sandbags5)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard"){
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addZombie), userInfo: nil, repeats: true)
        surTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addSurvivor), userInfo: nil, repeats: true)
    }
    
    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "player")
            liveNode.position = CGPoint(x: self.anchorPoint.x-200 - CGFloat(4-live)*liveNode.size.width, y: self.anchorPoint.y+600)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    
    @objc func addZombie () {
        possibleZombies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleZombies) as! [String]
        
        let zombie = SKSpriteNode(imageNamed: possibleZombies[0])
        
        let randomZombiePosition = GKRandomDistribution(lowestValue: -375, highestValue: 375)
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
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -zombie.size.height-200), duration: animationDuration))
        actionArray.append(SKAction.run {
            self.run(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))
            
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0{
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOverScene = GameOverScene(fileNamed: "GameOverScene") as! SKScene
                    let gameOver = gameOverScene as! GameOverScene
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                }
            }
        })
        actionArray.append(SKAction.removeFromParent())
        
        zombie.run(SKAction.sequence(actionArray))
    }
    
    @objc func addSurvivor () {

        let survivor = SKSpriteNode(imageNamed: "playerBig.png")

        let randomSurvivorPosition = GKRandomDistribution(lowestValue: -375, highestValue: 375)
        let position = CGFloat(randomSurvivorPosition.nextInt())

        survivor.position = CGPoint(x: position, y: self.frame.size.height + survivor.size.height)

        survivor.physicsBody = SKPhysicsBody(rectangleOf: survivor.size)
        survivor.physicsBody?.isDynamic = true

        survivor.physicsBody?.categoryBitMask = survivorCategory
        survivor.physicsBody?.contactTestBitMask = bulletCategory
        survivor.physicsBody?.collisionBitMask = 0

        survivor.xScale = 0.25
        survivor.yScale = 0.25

        self.addChild(survivor)

        let animationDuration:TimeInterval = 6

        var actionArray = [SKAction]()

        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -survivor.size.height-200), duration: animationDuration))
        actionArray.append(SKAction.run {
        self.run(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false))

        })
        actionArray.append(SKAction.removeFromParent())
        
        survivor.run(SKAction.sequence(actionArray))
    }
    
    
 
 //fire bullet based on point touched
    func fireBullet(position: CGPoint) {
        self.run(SKAction.playSoundFileNamed("gunSound.mp3", waitForCompletion: false))

        let bulletNode = SKSpriteNode(imageNamed: "bulet_3")
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
        
        actionArray.append(SKAction.move(to: CGPoint(x: position.x-300, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        bulletNode.run(SKAction.sequence(actionArray))
        
    }
    
    
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
        
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & survivorCategory) != 0 {
            bulletDidCollideWithSurvivor(bulletNode: firstBody.node as! SKSpriteNode, survivorNode: secondBody.node as! SKSpriteNode)
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
    
    func bulletDidCollideWithSurvivor (bulletNode:SKSpriteNode, survivorNode:SKSpriteNode) {
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "player")
            liveNode.position = CGPoint(x: self.anchorPoint.x-200 - CGFloat(4-live)*liveNode.size.width, y: self.anchorPoint.y+600)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = survivorNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        survivorNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch:UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self.view)
        print(touch.location(in: self.view))
        if positionInScene.y < 500{
            fireBullet(position: positionInScene)
        }
        else if positionInScene.x < 200
        {
            player.position.x -= 50;
        }
        else if positionInScene.x > 200
        {
             player.position.x += 50;
        }
    }
}
