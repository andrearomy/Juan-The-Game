//
//  GameScene.swift
//  Juan-The-Game
//

import SpriteKit
import CoreMotion

enum gameState {
    case started
    case playing
    case paused
    case over
    
    // controlla nell'update
}

class GameScene: SKScene {
    
    var motionManager: CMMotionManager!
    let horse = SKSpriteNode(imageNamed: "horse")
    var platforms = [SKSpriteNode]()
    var bottom = SKShapeNode()
    let scoreLabel = SKLabelNode(text: "Score: 0")
    var score = 0
    var highestScore = 0
    var isGameStarted = false
    let playJumpSound = SKAction.playSoundFileNamed("jump", waitForCompletion: false)
    let playCoinSound = SKAction.playSoundFileNamed("coin", waitForCompletion: false)
    let playFrogSound = SKAction.playSoundFileNamed("frog", waitForCompletion: false)
    let playPigSound = SKAction.playSoundFileNamed("pig", waitForCompletion: false)
    let playDuckSound = SKAction.playSoundFileNamed("duck", waitForCompletion: false)
    let playBirdSound = SKAction.playSoundFileNamed("bird", waitForCompletion: false)
    let playBreakSound = SKAction.playSoundFileNamed("break", waitForCompletion: false)
    var isSuperJumpOn = false
    var superJumpCounter: CGFloat = 0
    var playGameMusic = SKAudioNode(fileNamed: "gameMusic")
    var isInverted = false
    var startRainbow = false
    var yellowBorder = false
    
    let coinsKey = "CoinsCollected"
    
    var coinsCollected = 0 {
        didSet {
            // Save the updated value to UserDefaults
            UserDefaults.standard.set(coinsCollected, forKey: coinsKey)
        }
    }

    
    var rotationStartTime: TimeInterval?

    let scoreLabelBack = SKLabelNode(text: "Score: 0")
    var pausePanel: SKSpriteNode?
    

    func collectCoin() {
        // Increment the coinsCollected variable when a coin is collected
        coinsCollected += 1
        displayTotalCoins() // Update the displayed count
    }

    func updateCoinsLabel() {
        // Update the UI label with the current number of collected coins
        let coinLabel = childNode(withName: "CoinLabel") as? SKLabelNode
        coinLabel?.text = "Coins: \(coinsCollected)"
    }
    
    func displayTotalCoins() {
        // Retrieve the total coins collected from UserDefaults
        if let totalCoins = UserDefaults.standard.value(forKey: coinsKey) as? Int {
            coinsCollected = totalCoins
        }
        // Use coinsCollected to display or handle the total coins in your game UI
        updateCoinsLabel() // Call the function to update the label
    }
    
    override func didMove(to view: SKView) {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        layoutScene()
        displayTotalCoins()
        
        
        //        if isPaused {
        //            pauseGame()
        //            createPausePanel()
        //        }
    }
    
    func layoutScene() {
        playGameMusic.run(SKAction.changeVolume(to: 0.3, duration: 1))
        addBackground()
        addScoreCounter()
        spawnHorse()
        addBottom()
        makePlatforms()
        addChild(playGameMusic)
        
        let coinLabel = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
            coinLabel.text = ("\(SKSpriteNode(imageNamed: "coin"))\(coinsCollected)") // Display the initial count
            coinLabel.fontSize = 24
            coinLabel.fontColor = SKColor.white
            coinLabel.horizontalAlignmentMode = .center
            coinLabel.verticalAlignmentMode = .center
            coinLabel.position = CGPoint(x: frame.width - 330, y: frame.height - 50)
            coinLabel.zPosition = ZPositions.ui
            coinLabel.name = "CoinLabel" // Add a name to reference it later
            addChild(coinLabel) // Add the coin label as a child
        
        // Pause button
        let pauseButton = SKSpriteNode(imageNamed: "pauseButton")
        pauseButton.setScale(0.2)
        pauseButton.position = CGPoint(x: frame.width - 45, y: frame.height - 65)
        pauseButton.zPosition = ZPositions.ui
        pauseButton.name = "Pause"
        addChild(pauseButton)
        
    }
    
    func addBackground() {
        
        
        let background = SKSpriteNode(imageNamed: "background")
        
        background.position = CGPoint(x: frame.midX, y: 6500)
        //        background.size = background.texture!.size()
        
        //        background.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 5)
        background.zPosition = ZPositions.background
        
        background.name = "background" // Assegna un nome univoco
        
        let originalWidth = background.texture?.size().width ?? 1
        let originalHeight = background.texture?.size().height ?? 1
        
        let targetWidth = UIScreen.main.bounds.width
        let targetHeight = targetWidth / originalWidth * originalHeight
        
        background.size = CGSize(width: targetWidth, height: targetHeight)
        
        
        addChild(background)
    }
    
    
    
    func addScoreCounter() {
        
        scoreLabel.fontSize = 25
        scoreLabel.fontName = "PixelFJ8pt1Normal"
        scoreLabel.fontColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.horizontalAlignmentMode = .center // Set to center
        
        // Position scoreLabel at the top center of the screen
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.height - (view?.safeAreaInsets.top ?? 10) - 20)
        scoreLabel.zPosition = ZPositions.scoreLabel
        addChild(scoreLabel)
    }
    
    
    func spawnHorse() {
        horse.name = "Juan"
        horse.position = CGPoint(x: frame.midX, y: 20 + horse.size.height/2)
        horse.zPosition = ZPositions.horse
        horse.physicsBody = SKPhysicsBody(circleOfRadius: horse.size.width/2)
        horse.physicsBody?.affectedByGravity = true
        horse.physicsBody?.categoryBitMask = PhysicsCategories.horseCategory
        horse.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory | PhysicsCategories.cloudCategory | PhysicsCategories.duck | PhysicsCategories.birdCategory | PhysicsCategories.duck2 | PhysicsCategories.duck3 | PhysicsCategories.frogCategory | PhysicsCategories.pigCategory | PhysicsCategories.coinCategory
        horse.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(horse)
    }
    
    func addBottom() {
        bottom = SKShapeNode(rectOf: CGSize(width: frame.width*2, height: 20))
        bottom.position = CGPoint(x: frame.midX, y: 10)
        bottom.fillColor = UIColor.init(red: 79/255, green: 39/255, blue: 37/255, alpha: 1)
        bottom.strokeColor = bottom.fillColor
        bottom.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 20))
        bottom.physicsBody?.affectedByGravity = false
        bottom.physicsBody?.isDynamic = false
        bottom.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        addChild(bottom)
    }
    
    func makePlatforms() {
        let spaceBetweenPlatforms = frame.size.height/10
        for i in 0..<Int(frame.size.height/spaceBetweenPlatforms) {
            let x = CGFloat.random(in: 0...frame.size.width)
            let y = CGFloat.random(in: CGFloat(i)*spaceBetweenPlatforms+10...CGFloat(i+1)*spaceBetweenPlatforms-10)
            spawnPlatform(at: CGPoint(x: x, y: y))
        }
    }
    
    func spawnPlatform(at position: CGPoint) {
        var platform = SKSpriteNode()
        if position.x < frame.midX {
            platform = SKSpriteNode(imageNamed: "platformLeft")
        }
        else {
            platform = SKSpriteNode(imageNamed: "platformRight")
        }
        platform.position = position
        platform.zPosition = ZPositions.platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height/20))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platforms.append(platform)
        addChild(platform)
    }
    
    
    func explodeHorse() {
        // Pause the physics simulation for the horse
        horse.physicsBody?.isDynamic = false
        self.horse.isHidden = true

        let explosionContainer = SKNode()
        explosionContainer.position = horse.position
        addChild(explosionContainer)

        let explosionSprite = SKSpriteNode(imageNamed: "explosion1")
        explosionSprite.zRotation = 0  // Reset zRotation to zero
        explosionContainer.addChild(explosionSprite)

        var explosionAnimation: [SKTexture] = []
        for i in 1...8 {
            let frameName = "explosion\(i)"
            let texture = SKTexture(imageNamed: frameName)
            explosionAnimation.append(texture)
        }

        let animateAction = SKAction.animate(with: explosionAnimation, timePerFrame: 0.1, resize: true, restore: true)
        let sequence = SKAction.sequence([animateAction])
        
        explosionSprite.run(sequence) {
            explosionContainer.removeFromParent()
            self.goToMenuScene()
        }
    }


    func goToMenuScene() {
        // Transition to the menu scene
        let menuScene = MenuScene(size: view!.bounds.size)
        view?.presentScene(menuScene)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Check if the horse is rotating in the x-axis for more than 4 seconds
        if abs(horse.zRotation) > 0.1 {
            if rotationStartTime == nil {
                rotationStartTime = currentTime
            } else {
                let elapsedTime = currentTime - rotationStartTime!
                if elapsedTime > 4 {
                    explodeHorse()
                    rotationStartTime = nil // Reset rotation tracking
                }
            }
        } else {
            rotationStartTime = nil // Reset rotation tracking if not rotating
        }

        checkPhoneTilt()
        if isGameStarted {
            checkHorsePosition()
            checkHorseVelocity()
            updatePlatformsPositions()
            checkYellowBorder()
        }
    }

    
    func checkYellowBorder() {
        if isInverted {
            if !yellowBorder{
                
                let side1 = SKShapeNode()
                side1.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: 20), cornerRadius: 30).cgPath
                side1.position = CGPoint(x: 0, y: frame.maxY)
                side1.strokeColor = .yellow
                side1.glowWidth = 30
                side1.lineWidth = 15
                
                let side2 = SKShapeNode()
                side2.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 20, height: frame.height), cornerRadius: 30).cgPath
                side2.position = CGPoint(x: frame.maxX-15, y: 0)
                side2.strokeColor = .yellow
                side2.glowWidth = 30
                side2.lineWidth = 15
                
                let side3 = SKShapeNode()
                side3.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: 20), cornerRadius: 30).cgPath
                side3.position = CGPoint(x: 0, y: 0)
                side3.strokeColor = .yellow
                side3.glowWidth = 30
                side3.lineWidth = 15
                
                let side4 = SKShapeNode()
                side4.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 20, height: frame.height), cornerRadius: 30).cgPath
                side4.position = CGPoint(x: 0, y: 0)
                side4.strokeColor = .yellow
                side4.glowWidth = 30
                side4.lineWidth = 15
                
                addChild(side1)
                addChild(side2)
                addChild(side3)
                addChild(side4)
                
                let action1 = SKAction.move(to: CGPoint(x: frame.maxX, y: frame.maxY), duration: 0.75)
                side1.run(action1)
                
                let action2 = SKAction.move(to: CGPoint(x: frame.maxX, y: -frame.maxY), duration: 0.75)
                
                
                let action3 = SKAction.move(to: CGPoint(x: -frame.maxX, y: 0), duration: 0.75)
                
                
                let action4 = SKAction.move(to: CGPoint(x: 0, y: frame.maxY), duration: 0.75)
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    side1.removeFromParent()
                    side2.run(action2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        side2.removeFromParent()
                        side3.run(action3)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                            side3.removeFromParent()
                            side4.run(action4)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                side4.removeFromParent()
                            }
                        }
                    }
                }
                
                
                yellowBorder = true
            }
        }
    }
    
    func checkPhoneTilt() {
        var defaultAcceleration = 9.8
        if let accelerometerData = motionManager.accelerometerData {
            var xAcceleration = accelerometerData.acceleration.x * 20
            if xAcceleration > defaultAcceleration {
                xAcceleration = defaultAcceleration
            }
            else if xAcceleration < -defaultAcceleration {
                xAcceleration = -defaultAcceleration
            }
            if score > 10000 {
                xAcceleration = accelerometerData.acceleration.x * 30
            }
            else if score > 8000 {
                xAcceleration = accelerometerData.acceleration.x * 23
            }else if score > 5000 {
                xAcceleration = accelerometerData.acceleration.x * 22
            }else if score > 3000 {
                xAcceleration = accelerometerData.acceleration.x * 21
            }
            horse.run(SKAction.rotate(toAngle: CGFloat(-xAcceleration/5), duration: 0.15))
            
            // Clamping the acceleration within a range
            xAcceleration = min(max(xAcceleration, -defaultAcceleration), defaultAcceleration)
            
            if isGameStarted {
                if isSuperJumpOn {
                    defaultAcceleration = -0.1
                }
                
                let targetRotation = CGFloat(-xAcceleration / 5)
                let rotateAction = SKAction.rotate(toAngle: targetRotation, duration: 0.15, shortestUnitArc: true)
                horse.run(rotateAction)
                
                if isInverted {
                    physicsWorld.gravity = CGVector(dx: -xAcceleration, dy: -defaultAcceleration)
                } else {
                    physicsWorld.gravity = CGVector(dx: xAcceleration, dy: -defaultAcceleration)
                }
            }
        }
    }
    
    
    func checkHorsePosition() {
        let horseWidth = horse.size.width
        if horse.position.y+horseWidth < 0 {
            //            self.removeAllActions()
            playGameMusic.run(SKAction.stop())
            
            run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
            saveScore()
            let menuScene = MenuScene.init(size: view!.bounds.size)
            
            view?.presentScene(menuScene)
        }
        setScore()
        if horse.position.x-horseWidth >= frame.size.width || horse.position.x+horseWidth <= 0 {
            fixHorsePosition()
        }
    }
    
    func saveScore() {
        UserDefaults.standard.setValue(highestScore, forKey: "LastScore")
        if highestScore > UserDefaults.standard.integer(forKey: "HighScore") {
            UserDefaults.standard.setValue(highestScore, forKey: "HighScore")
        }
    }
    
    func setScore() {
        let oldScore = score
        score = (Int(horse.position.y) - Int(horse.size.height/2)) - (Int(bottom.position.y) - Int(bottom.frame.size.height)/2)
        score = score < 0 ? 0 : score
        if score > oldScore {
            
            if score > 10000 {
                if !startRainbow {
                    let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .purple]
                    var indexColor = 0
                    DispatchQueue.global(qos: .background).async {
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
                            indexColor = indexColor == 6 ? 0 : indexColor
                            self.scoreLabel.fontColor = colors[indexColor]
                            indexColor+=1
                        }
                        RunLoop.current.run()
                    }
                    startRainbow = true
                }
            }else if score > 8000 {
                scoreLabel.fontColor = UIColor.systemRed
            }else if score > 5000 {
                scoreLabel.fontColor = UIColor.systemOrange
            }else if score > 3000 {
                scoreLabel.fontColor = UIColor.systemYellow
            }
            //            scoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            if score > highestScore {
                highestScore = score
            }
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        scoreLabel.text = "Score: " + (formattedScore ?? "0")
        
        scoreLabelBack.text = "Score: " + (formattedScore ?? "0")
    }
    
    func checkHorseVelocity() {
        if let horseVelocity = horse.physicsBody?.velocity.dx {
            if horseVelocity > 700 {
                horse.physicsBody?.velocity.dx = 700
            }
            else if horseVelocity < -700 {
                horse.physicsBody?.velocity.dx = -700
            }
        }
    }
    
    func updatePlatformsPositions() {
        var minimumHeight: CGFloat = frame.size.height/2
        guard let horseVelocity = horse.physicsBody?.velocity.dy else {
            return
        }
        var distance = horseVelocity/50
        if isSuperJumpOn {
            minimumHeight = 0
            distance = 30 - superJumpCounter
            superJumpCounter += 0.16
        }
        if horse.position.y > minimumHeight && horseVelocity > 0 {
            for platform in platforms {
                platform.position.y -= distance
                if platform.position.y < 0-platform.frame.size.height/2 {
                    update(platform: platform, positionY: platform.position.y)
                }
            }
            bottom.position.y -= distance
            
            if let background = childNode(withName: "background") as? SKSpriteNode {
                background.position.y -= distance
            }
        }
    }
    
    func update(platform: SKSpriteNode, positionY: CGFloat) {
        platform.position.x = CGFloat.random(in: 0...frame.size.width)
        
        var direction = "Left"
        if platform.position.x > frame.midX {
            direction = "Right"
        }
        
        platform.removeAllActions()
        platform.alpha = 1.0
        if Int.random(in: 1...80) == 1{
            if Int.random(in: 1...10) == 1 {
                platform.texture = SKTexture(imageNamed: "duck")
                updateSizeOf(platform: platform)
                platform.physicsBody?.categoryBitMask = PhysicsCategories.duck
            }
            else if Int.random(in: 1...20) == 1 {
                platform.texture = SKTexture(imageNamed: "duck2")
                updateSizeOf(platform: platform)
                platform.physicsBody?.categoryBitMask = PhysicsCategories.duck2
            }
            else if Int.random(in: 1...30) == 1 {
                platform.texture = SKTexture(imageNamed: "duck3")
                updateSizeOf(platform: platform)
                platform.physicsBody?.categoryBitMask = PhysicsCategories.duck3
            }
        }
        else if Int.random(in: 1...7) == 1 {
            platform.texture = SKTexture(imageNamed: "pig" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.pigCategory
            if direction == "Left" {
                platform.position.x = 0
                animate(platform: platform, isLeft: true)
            }
            else {
                platform.position.x = frame.size.width
                animate(platform: platform, isLeft: false)
            }
        }
        else if Int.random(in: 1...2) == 1 {
            platform.texture = SKTexture(imageNamed: "platformBird" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.birdCategory
            if direction == "Left" {
                platform.position.x = 0
                animate(platform: platform, isLeft: true)
            }
            else {
                platform.position.x = frame.size.width
                animate(platform: platform, isLeft: false)
            }
        }
        else if Int.random(in: 1...40) == 1 {
            platform.texture = SKTexture(imageNamed: "platformFrog")
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.frogCategory
        }
        else if Int.random(in: 1...10) == 1 {
            platform.texture = SKTexture(imageNamed: "coin")
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.coinCategory
        }

        else if Int.random(in: 1...7) == 1 {
            platform.texture = SKTexture(imageNamed: "cloud" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.cloudCategory
        }
        else {
            platform.texture = SKTexture(imageNamed: "platform" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        }
        
        
        platform.position.y = frame.size.height + platform.frame.size.height/2 + platform.position.y
    }
    
    func updateSizeOf(platform: SKSpriteNode) {
        if let textureSize = platform.texture?.size() {
            platform.size = CGSize(width: textureSize.width, height: textureSize.height)
            platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height/20))
            platform.physicsBody?.isDynamic = false
            platform.physicsBody?.affectedByGravity = false
        }
    }
    
    func animate(platform: SKSpriteNode, isLeft: Bool) {
        let distanceX = isLeft ? frame.size.width : -frame.size.width
        platform.run(SKAction.moveBy(x: distanceX, y: 0, duration: 2)) {
            platform.run(SKAction.moveBy(x: -distanceX, y: 0, duration: 2)) {
                self.animate(platform: platform, isLeft: isLeft)
            }
        }
    }
    
    func fixHorsePosition() {
        let horseWidth = horse.size.width
        if horse.position.x >= frame.size.width {
            horse.position.x = 0 - horseWidth/2+1
        }
        else {
            horse.position.x = frame.size.width + horseWidth/2-1
        }
    }
    
    //    func fpauseGame() {
    //        isPaused = true
    //        playGameMusic.run(SKAction.pause())
    //    }
    
    let muteButton = SKSpriteNode(imageNamed: "muteButton")
    let unmuteButton = SKSpriteNode(imageNamed: "unmuteButton")

    var isMusicMuted: Bool = false
    
    
//    var muteButton: SKSpriteNode!
//    var unmuteButton: SKSpriteNode!

    
    func createPausePanel() {
        // Panel
        pausePanel = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: frame.width, height: frame.height))
        pausePanel?.position = CGPoint(x: frame.midX, y: frame.midY)
        pausePanel?.zPosition = ZPositions.ui + 1
        addChild(pausePanel!)
        
        // Add here other items for example mute song
        
        // Resume Button
        let resumeButton = SKSpriteNode(imageNamed: "resumeButton")
        resumeButton.setScale(0.4)
        resumeButton.zPosition = ZPositions.ui + 2
        resumeButton.name = "Resume"
        pausePanel?.addChild(resumeButton)
        
        // Exit Button
        let exitButton = SKSpriteNode(imageNamed: "exitButton")
        exitButton.setScale(0.4)
        exitButton.zPosition = ZPositions.ui + 2
        exitButton.name = "Exit"
        pausePanel?.addChild(exitButton)
        
        // Mute Button
//        let muteButton = SKSpriteNode(imageNamed: "muteButton")
        muteButton.setScale(0.4)
        muteButton.zPosition = ZPositions.ui + 2
        muteButton.name = "Mute"
        pausePanel?.addChild(muteButton)
        
        // Unmute Button
//        let unmuteButton = SKSpriteNode(imageNamed: "unmuteButton")
        unmuteButton.setScale(0.4)
        unmuteButton.zPosition = ZPositions.ui + 2
        unmuteButton.name = "Unmute"
        pausePanel?.addChild(unmuteButton)
        
//        // Set initial button visibility based on mute state
//        muteButton.isHidden = false
//        unmuteButton.isHidden = true
        
        
        muteButton.isHidden = isMusicMuted
        unmuteButton.isHidden = !isMusicMuted
        
        // Set positions
        let buttonSeparation: CGFloat = 50.0 // Adjust this value based on your preference
        let totalHeight = resumeButton.size.height + buttonSeparation + exitButton.size.height + muteButton.size.height

        resumeButton.position = CGPoint(x: 0, y: totalHeight / 2 - resumeButton.size.height / 2)
        exitButton.position = CGPoint(x: 0, y: resumeButton.position.y - resumeButton.size.height / 2 - buttonSeparation - exitButton.size.height / 2)
        muteButton.position = CGPoint(x: 0, y: exitButton.position.y - exitButton.size.height / 2 - buttonSeparation - muteButton.size.height / 2)
        unmuteButton.position = CGPoint(x: 0, y: exitButton.position.y - exitButton.size.height / 2 - buttonSeparation - muteButton.size.height / 2)

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "Pause" {
            UserDefaults.standard.setValue(true, forKey: "isPaused")
            isPaused = true
            playGameMusic.run(SKAction.pause())
            createPausePanel()
        } else if node.name == "Resume" {
            isPaused = false
            if !isMusicMuted {
                playGameMusic.run(SKAction.play())
            }
            pausePanel?.removeFromParent()
        } else if node.name == "Exit" {
            let menuScene = MenuScene.init(size: view!.bounds.size)
            view?.presentScene(menuScene)
        } else if node.name == "Mute" {
            muteButton.isHidden = true
            unmuteButton.isHidden = false
            isMusicMuted = true
            playGameMusic.run(SKAction.pause())
        } else if node.name == "Unmute" {
            muteButton.isHidden = false
            unmuteButton.isHidden = true
            isMusicMuted = false
            playGameMusic.run(SKAction.play())
        } else if !isGameStarted {
            horse.physicsBody?.velocity.dy = frame.size.height * 1.2 - horse.position.y
            isGameStarted = true
            run(playJumpSound)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if let horseVelocity = horse.physicsBody?.velocity.dy {
            if horseVelocity < 0 {
                if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.platformCategory {
                    run(playJumpSound)
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.pigCategory {
                    run(playPigSound)
                    run(playJumpSound)
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.cloudCategory {
                    run(playJumpSound)
                    run(playBreakSound)
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                    if let platform = (contact.bodyA.node?.name != "Horse") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.duck {
                    run(SKAction.playSoundFileNamed("superJump", waitForCompletion: false))
                    run(playDuckSound)
                    horse.physicsBody?.velocity.dy = 8
                    isSuperJumpOn = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSuperJumpOn = false
                        self.superJumpCounter = 0
                    }
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.coinCategory {
                    run(playCoinSound)
                    collectCoin()
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                    if let platform = (contact.bodyA.node?.name != "Horse") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.duck2 {
                    run(SKAction.playSoundFileNamed("superJump", waitForCompletion: false))
                    run(playDuckSound)
                    horse.physicsBody?.velocity.dy = 10
                    isSuperJumpOn = true
                    superJumpCounter = -10
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSuperJumpOn = false
                        self.superJumpCounter = 0
                    }
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.duck3 {
                    run(SKAction.playSoundFileNamed("superJump", waitForCompletion: false))
                    run(playDuckSound)
                    horse.physicsBody?.velocity.dy = 10
                    isSuperJumpOn = true
                    superJumpCounter = -25
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSuperJumpOn = false
                        self.superJumpCounter = 0
                    }
                }
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.frogCategory {
                    run(playJumpSound)
                    run(playFrogSound)
                    run(playBreakSound)
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                    if let platform = (contact.bodyA.node?.name != "Horse") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                    if let horse = (contact.bodyA.node as? SKSpriteNode)?.name == "Juan" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        let shrinkAction = SKAction.scale(by: 0.5, duration: 0.5)
                        let revertAction = SKAction.scale(to: 1.0, duration: 0.5)
                        
                        // Sequence the actions: Shrink -> Wait for 5 seconds -> Revert
                        let sequenceAction = SKAction.sequence([shrinkAction, SKAction.wait(forDuration: 5.0), revertAction])
                        
                        // Run the sequence action on the horse
                        horse.run(sequenceAction)
                    }
                }
                else if contactMask == PhysicsCategories.birdCategory | PhysicsCategories.horseCategory{
                    isInverted = true
                    run(playBirdSound)
                    run(playJumpSound)
                    run(playBreakSound)
                    horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
                    if let platform = (contact.bodyA.node?.name != "Horse") ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                        platform.physicsBody?.categoryBitMask = PhysicsCategories.none
                        platform.run(SKAction.fadeOut(withDuration: 0.5))
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isInverted = false
                        self.yellowBorder = false
                    }
                }
            }
        }
    }
}
