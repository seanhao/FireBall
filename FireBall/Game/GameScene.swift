//
//  GameScene.swift
//  FireBall
//
//  Created by Sean on 24/04/2018.
//  Copyright © 2018 seanhao. All rights reserved.
//

//有空看一下這篇
//https://hk.saowen.com/a/460d27b84528d7b0776ee69b0fb4b1b9ca48fff934b1776d876a944311250798
import SpriteKit
import GameplayKit
//CoreMotion https://my.oschina.net/CarlHuang/blog/138431
import CoreMotion
//SKPhysicsContactDelegate:Methods your app can implement to respond when physics bodies come into contact.
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var starfield:SKEmitterNode!
    var summon:SKSpriteNode!
    var player:SKSpriteNode!
    
    var leftButtonNode:SKSpriteNode!
    var rightButtonNode:SKSpriteNode!
    var attackButtonNode:SKSpriteNode!
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "KILL: \(score)"
        }
    }
    
    //血量
    var healthLabel:SKLabelNode!
    var health:Int = 100 {
        didSet {
            healthLabel.text = "HP: \(health)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleMonsters = ["monster1", "monster2", "monster3"]
    
    //http://www.cnblogs.com/jztsdwn/p/6868809.html 不一定是對的
    //0x1 << 1 = 2   0x1 << 0 = 1
    let monsterCategory:UInt32 = 0x1 << 1
    let photonFireballCategory:UInt32 = 0x1 << 0
    
    override func didMove(to view: SKView) {
        
        //addLive()
        
        attackButtonNode = self.childNode(withName: "attackButton") as! SKSpriteNode
        leftButtonNode = self.childNode(withName: "leftButton") as! SKSpriteNode
        rightButtonNode = self.childNode(withName: "rightButton") as! SKSpriteNode

        summon = SKSpriteNode(imageNamed: "SummonCircle")
        summon.position = CGPoint(x:180, y: 640)
        self.addChild(summon)
        summon.zPosition = -1

        player = SKSpriteNode(imageNamed: "Magician")
        
        player.position = CGPoint(x: 180, y: 0)
        
        self.addChild(player)
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //A delegate that is called when two physics bodies come in contact with each other.
        //???
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 50, y: 20)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        //血量
        healthLabel = SKLabelNode(text: "HP: 100")
        healthLabel.position = CGPoint(x: 50, y: 40)
        healthLabel.fontName = "AmericanTypewriter-Bold"
        healthLabel.fontSize = 20
        healthLabel.fontColor = UIColor.white
        health = 100
        self.addChild(healthLabel)
        
        //難度
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard"){
            timeInterval = 0.1
            }
            
        //selector => 定時執行哪一個func
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addMonster), userInfo: nil, repeats: true)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view?.isMultipleTouchEnabled = true
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "attackButton" {
                fireFireball()
            }
            if leftButtonNode.contains(location) {
                movePlayer(moveBy: -100, forTheKey: "left")
            }
            
            if rightButtonNode.contains(location) {
                movePlayer(moveBy: 100, forTheKey: "right")
            }
        }
        
        
    }
    
    func movePlayer (moveBy: CGFloat, forTheKey: String) {
        let moveAction = SKAction.moveBy(x: moveBy, y: 0, duration: 1)
        let repeatForEver = SKAction.repeatForever(moveAction)
        let seq = SKAction.sequence([moveAction, repeatForEver])
        
        //run the action on your ship
        player.run(seq, withKey: forTheKey)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.removeAction(forKey: "left")
        player.removeAction(forKey: "right")
    }
    /*
    func addLive(){
        livesArray = [SKSpriteNode]()
        
        for live in 1 ... 3 {
            let liveNode = SKSpriteNode(imageNamed: "shuttle")
            liveNode.position = CGPoint(x: self.frame.size.width - 20, y:self.frame.size.height - 60)
            self.addChild(liveNode)
            livesArray.append(liveNode)
        }
    }
    */
    
    @objc func addMonster() {
        //sharedRandom:Returns a shared instance that shares a system-wide random source.
        possibleMonsters = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleMonsters) as! [String]
        
        let monster = SKSpriteNode(imageNamed: possibleMonsters[0])
        
        //GKRandomDistribution: Creates a random distribution with the specified lower and upper bounds, using the Arc4 randomizer.
        let randomMonsterPosition = GKRandomDistribution(lowestValue: 0, highestValue: 640)
        
        //nextInt(): Generates and returns a new random integer within the bounds of the distribution.
        let position = CGFloat(randomMonsterPosition.nextInt())
        
        //物件起點
        monster.position = CGPoint(x: position, y: self.frame.size.height)
        
        //SKPhysicsBod:An object which adds physics simulation to a node.
        //SKPhysicsBody(矩形: monster.size)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        //A Boolean value that indicates whether the physics body is moved by the physics simulation.
        monster.physicsBody?.isDynamic = true
        
        //碰撞實現 https://www.jianshu.com/p/493686eaf0d7 physicsBody屬性兩種
        //categoryBitMask设置物理体的标识符
        //contactTestBitMask可与哪一类的物理体发生碰撞
        monster.physicsBody?.categoryBitMask = monsterCategory
        monster.physicsBody?.contactTestBitMask = photonFireballCategory
        //A mask that defines which categories of physics bodies can collide with this physics body.
        monster.physicsBody?.collisionBitMask = 0
        
        self.addChild(monster)
        
        //TimeInterval每個迴圈速度 越短難度越高
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        //設定動畫到哪
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -650), duration: animationDuration))
        
        //撞到主角
        actionArray.append(SKAction.run {
            //self.run(SKAction.playSoundFileNamed("loose.mo3", waitForCompletion: false))
            
            if self.health > 0 {
                self.health -= 1
                
                if self.health == 0 {
                    //GameOverScreen Transition
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                    
                }
            }
            
            
            
            /*
            if self.livesArray.count > 0 {
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0 {
                    //GameOverScreen Transition
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOver.score = self.score
                    self.view?.presentScene(gameOver, transition: transition)
                    
                }
            }
             */
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        monster.run(SKAction.sequence(actionArray))
        
    }
    
    func fireFireball() {
        self.run(SKAction.playSoundFileNamed("din.mp3", waitForCompletion: false))
        
        let fireballNode = SKSpriteNode(imageNamed: "fireball")
        fireballNode.position = player.position
        fireballNode.position.y += 5
        
        fireballNode.physicsBody = SKPhysicsBody(circleOfRadius: fireballNode.size.width / 2)
        fireballNode.physicsBody?.isDynamic = true
        
        fireballNode.physicsBody?.categoryBitMask = photonFireballCategory
        fireballNode.physicsBody?.contactTestBitMask = monsterCategory
        fireballNode.physicsBody?.collisionBitMask = 0
        fireballNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(fireballNode)
        
        let animationDuration:TimeInterval = 1
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        fireballNode.run(SKAction.sequence(actionArray))
        
        
        
    }

    
    
    
    //didBegin:Called when two bodies first contact each other.
    //SKPhysicsContact:A description of the contact between two physics bodies.
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
        
        if (firstBody.categoryBitMask & photonFireballCategory) != 0 && (secondBody.categoryBitMask & monsterCategory) != 0 {
            fireballDidCollideWithMonster(fireballNode: firstBody.node as! SKSpriteNode, monsterNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func fireballDidCollideWithMonster (fireballNode:SKSpriteNode, monsterNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Fire")!
        explosion.position = monsterNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        fireballNode.removeFromParent()
        monsterNode.removeFromParent()
        
        
        self.run(  .wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        
        score += 1
        
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
