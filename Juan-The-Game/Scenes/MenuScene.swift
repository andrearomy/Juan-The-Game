//
//  MenuScene.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 05/12/23.
//

import SpriteKit

class MenuScene: SKScene {
    
    let logo = SKSpriteNode(imageNamed: "logo")
    
    override func didMove(to view: SKView) {
        addBackground()
        addLogo()
        addLastScore()
        addHighScore()
        addPlayButton()
    }
    
    func addBackground() {
            let background = SKSpriteNode(imageNamed: "bgmain")
            background.position = CGPoint(x: frame.midX, y: frame.midY)
    //        background.size = background.texture!.size()
            background.size = self.size
            background.zPosition = ZPositions.background
            addChild(background)
        }
    
    func addLogo() {
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        
        logo.setScale(0.7)
        
        logo.position = CGPoint(x: frame.midX - 20, y: topPosition - (logo.size.height/5) - 300 )
        logo.zPosition = ZPositions.logo
        addChild(logo)
    }
    
    func addLastScore() {
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        
        let lastScore = UserDefaults.standard.integer(forKey: "LastScore")
        let formattedScore = formatScore(from: lastScore)
        
        let lastScoreLabel = SKLabelNode(text: "Last Score: " + (formattedScore ?? "0"))
        lastScoreLabel.fontSize = 24.0
        lastScoreLabel.fontName = "HelveticaNeue-Light"
        lastScoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        lastScoreLabel.position = CGPoint(x: frame.midX, y: topPosition - (logo.size.height/8) - 15)
//        lastScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 20)
        lastScoreLabel.zPosition = CGFloat.greatestFiniteMagnitude
//        lastScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(lastScoreLabel)
        
    }
    
    func formatScore(from score: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        return formattedScore
    }
    
    func addHighScore() {
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        let formattedScore = formatScore(from: highScore)
        
        let highScoreLabel = SKLabelNode(text: "Highest score: " + (formattedScore ?? "0"))
        highScoreLabel.fontSize = 24.0
        highScoreLabel.fontName = "HelveticaNeue-Bold"
        highScoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        highScoreLabel.position = CGPoint(x: frame.midX, y: topPosition - (logo.size.height/8) - 55)
//        highScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 52)
        highScoreLabel.zPosition = CGFloat.greatestFiniteMagnitude
//        highScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(highScoreLabel)
    }

    func addPlayButton() {
        let playButton = SKSpriteNode(imageNamed: "playButton")
        playButton.position = CGPoint(x: frame.midX, y: frame.midY / 4)
        playButton.zPosition = ZPositions.logo
        addChild(playButton)
        
        playButton.name = "playButton"
    }
    
    /*
        OLD CODE:
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let gameScene = GameScene(size: view!.bounds.size)
            view?.presentScene(gameScene)
         }
    */
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "playButton" {
                playButtonTapped()
            }
        }
    }

    func playButtonTapped() {
        let gameScene = GameScene(size: view!.bounds.size)
        view?.presentScene(gameScene)
    }

    
}
