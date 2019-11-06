//
//  MenuScene.swift
//  FireBall
//
//  Created by Sean on 06/05/2018.
//  Copyright © 2018 seanhao. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    //var starfield:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        //starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        //starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        
        //difficultyButtonNode.texture = SKTexture(imageNamed: "difficultyButton")
        
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        
        //NSUserDefaults或者UserDefaults是一个分层的持续进程间分布(可选)键值存储优化存储用户设置。
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hard") {
            difficultyLabelNode.text = "Hard"
        }else{
            difficultyLabelNode.text = "Easy"
        }
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "newGameButton"{
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: transition)
                
            } else if atPoint(touchLocation).name == "difficultyButton" {
                changeDifficulty()
            }
        }
        /*
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "difficultyButton" {
                changeDifficulty()
            }
        }*/
        
    }
    
    func changeDifficulty() {
        let userDefaults = UserDefaults.standard
        
        if difficultyLabelNode.text == "Easy" {
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
        }else{
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey: "hard")
            
        }
        
        userDefaults.synchronize()
        
    }
    
}
