//
//  MenuScene.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 05/12/23.
//

import SpriteKit

class MenuScene: SKScene {
    
    let logo = SKSpriteNode(imageNamed: "logo")
    let juan = SKSpriteNode(imageNamed: "juan")
    
    override func didMove(to view: SKView) {
        addBackground()
        addText()
        addLogo()
        addLastScore()
        addHighScore()
        addPlayButton()
        addShopButton()
    }
    
    func createButtonAnimation() -> SKAction {
        let buttonFrames = ["playbutton1", "playbutton2"]
        
        var frames: [SKTexture] = []
        for frameName in buttonFrames {
            frames.append(SKTexture(imageNamed: frameName))
        }
        
        let buttonAnimation = SKAction.animate(with: frames, timePerFrame: 0.6)
        let repeatAction = SKAction.repeatForever(buttonAnimation)
        
        return repeatAction
    }
    
    func createEyeAnimation() -> SKAction {
        let eyeFrames = ["logo", "logo2"]
        var frames: [SKTexture] = []
        for frameName in eyeFrames {
            frames.append(SKTexture(imageNamed: frameName))
        }
        let eyeAnimation = SKAction.animate(with: frames, timePerFrame: 0.7)
        let repeatAction = SKAction.repeatForever(eyeAnimation)
        return repeatAction
    }
    
    func addShopButton() {
        let shopButton = SKSpriteNode(imageNamed: "shopButtonImageName")
        shopButton.position = CGPoint(x: frame.midX+150, y: frame.midY / 4.5) // Adjust the position as needed
        shopButton.zPosition = ZPositions.logo
        addChild(shopButton)
        
        shopButton.name = "shopButton"
        
        // Add animation or any visual feedback for the button
        let buttonAnimation = createButtonAnimation()
        shopButton.run(buttonAnimation)
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
        
        logo.setScale(0.67)
        
        logo.position = CGPoint(x: frame.midX - 30, y: topPosition - (logo.size.height/5) - 250 )
        logo.zPosition = ZPositions.logo
        addChild(logo)
        logo.name = "logo"
        let eyeAnimation = createEyeAnimation()
        logo.run(eyeAnimation)
    }
    
    
    func addText(){
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        
        juan.setScale(0.3)
        
        juan.position = CGPoint(x: frame.midX + 90, y: topPosition - (logo.size.height/5) - 460 )
        juan.zPosition = ZPositions.logo
        addChild(juan)
        
    }
    
    func addLastScore() {
        //        for name in UIFont.familyNames {
        //            print(name)
        //            if let nameString = name as? String {
        //                print(UIFont.fontNames(forFamilyName: nameString))
        //            }
        //        }
        let topPosition = frame.height - (view?.safeAreaInsets.top ?? 10)
        
        let lastScore = UserDefaults.standard.integer(forKey: "LastScore")
        let formattedScore = formatScore(from: lastScore)
        
        let lastScoreLabel = SKLabelNode(text: "Last Score: " + (formattedScore ?? "0"))
        lastScoreLabel.fontSize = 15
        lastScoreLabel.fontName = "PixelFJ8pt1Normal"
        lastScoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        lastScoreLabel.position = CGPoint(x: frame.midX, y: topPosition - (logo.size.height/8) - 45)
        //        lastScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 20)
        lastScoreLabel.zPosition = CGFloat.greatestFiniteMagnitude
        //        lastScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(lastScoreLabel)
        
        let lastScoreLabelShadow = SKLabelNode(text: "Last Score: " + (formattedScore ?? "0"))
        lastScoreLabelShadow.fontSize = 15
        lastScoreLabelShadow.fontName = "PixelFJ8pt1Normal"
        lastScoreLabelShadow.fontColor = .black
        lastScoreLabelShadow.position = CGPoint(x: frame.midX+2, y: topPosition - (logo.size.height/8) - 45 - 2)
        //        lastScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 20)
        lastScoreLabelShadow.zPosition = 0
        //        lastScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(lastScoreLabelShadow)
        
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
        
        let highScoreLabel = SKLabelNode(text: "Highest Score: " + (formattedScore ?? "0"))
        highScoreLabel.fontSize = 25
        highScoreLabel.fontName = "PixelFJ8pt1Normal"
        highScoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        highScoreLabel.position = CGPoint(x: frame.midX, y: topPosition - (logo.size.height/8) - 15)
        //        highScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 52)
        highScoreLabel.zPosition = CGFloat.greatestFiniteMagnitude
        //        highScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(highScoreLabel)
        
        let highScoreLabelShadow = SKLabelNode(text: "Highest Score: " + (formattedScore ?? "0"))
        highScoreLabelShadow.fontSize = 25
        highScoreLabelShadow.fontName = "PixelFJ8pt1Normal"
        highScoreLabelShadow.fontColor = .black
        highScoreLabelShadow.position = CGPoint(x: frame.midX+2, y: topPosition - (logo.size.height/8) - 15 - 2)
        //        highScoreLabel.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - 52)
        highScoreLabelShadow.zPosition = 0
        //        highScoreLabel.zPosition = ZPositions.scoreLabel
        addChild(highScoreLabelShadow)
    }
    
    func addPlayButton() {
        let playButton = SKSpriteNode(imageNamed: "playbutton1")
        playButton.position = CGPoint(x: frame.midX-50, y: frame.midY / 4.5)
        playButton.zPosition = ZPositions.logo
        addChild(playButton)
        
        playButton.name = "playbutton1"
        
        let buttonAnimation = createButtonAnimation()
        playButton.run(buttonAnimation)
    }
    
    /*
     Velocità accellerometro
     
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
            
            if touchedNode.name == "playbutton1" {
                playButtonTapped()
            } else if touchedNode.name == "shopButton" {
                shopButtonTapped()
            }
        }
    }
    
    func shopButtonTapped() {
        let shopScene = ShopScene(size: view!.bounds.size)
        view?.presentScene(shopScene, transition: .fade(withDuration: 0.5))
    }
    
    
    func playButtonTapped() {
        //        run(playGameMusic, withKey: "gameMusic")
        let gameScene = GameScene(size: view!.bounds.size)
        
        
        //        let gameScene = GameScene_editBg(size: view!.bounds.size)
        view?.presentScene(gameScene)
    }
    
    
}
