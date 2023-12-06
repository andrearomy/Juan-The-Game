//
//  GameScene.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 05/12/23.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    var motionManager: CMMotionManager!
    let horse = SKSpriteNode(imageNamed: "horse")
    var platforms = [SKSpriteNode]()
    var bottom = SKShapeNode()
    let platform1 = SKSpriteNode(imageNamed: "platform1")
    let scoreLabel = SKLabelNode(text: "Score: 0")
    var score = 0
    var highestScore = 0
    var isGameStarted = false
    let playJumpSound = SKAction.playSoundFileNamed("jump", waitForCompletion: false)
    let playBreakSound = SKAction.playSoundFileNamed("break", waitForCompletion: false)
    var isSuperJumpOn = false
    var superJumpCounter: CGFloat = 0
    
    override func didMove(to view: SKView) {
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        layoutScene()
    }
    
    func layoutScene() {
        addBackground()
        addScoreCounter()
        spawnHorse()
        addBottom()
        makePlatforms()
    }
    
    func addBackground() {
            let background = SKSpriteNode(imageNamed: "background")
            background.position = CGPoint(x: frame.midX, y: frame.midY)
    //        background.size = background.texture!.size()
            background.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            background.zPosition = ZPositions.background
            addChild(background)
        }
    
    func addScoreCounter() {
        scoreLabel.fontSize = 30.0
        scoreLabel.fontName = "HelveticaNeue-Bold"
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
        horse.physicsBody?.contactTestBitMask = PhysicsCategories.platformCategory | PhysicsCategories.dollarWithHoleCategory | PhysicsCategories.duck
        horse.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(horse)
    }
    
    func addBottom() {
        bottom = SKShapeNode(rectOf: CGSize(width: frame.width*2, height: 20))
        bottom.position = CGPoint(x: frame.midX, y: 10)
        bottom.fillColor = UIColor.init(red: 25/255, green: 105/255, blue: 81/255, alpha: 1)
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
            platform = SKSpriteNode(imageNamed: "dollarLeft")
        }
        else {
            platform = SKSpriteNode(imageNamed: "dollarRight")
        }
        platform.position = position
        platform.zPosition = ZPositions.platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
        platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platforms.append(platform)
        addChild(platform)
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkPhoneTilt()
        if isGameStarted {
            checkHorsePosition()
            checkHorseVelocity()
            updatePlatformsPositions()
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
            horse.run(SKAction.rotate(toAngle: CGFloat(-xAcceleration/5), duration: 0.15))
            if isGameStarted {
                if isSuperJumpOn {
                    defaultAcceleration = -0.1
                }
                physicsWorld.gravity = CGVector(dx: xAcceleration, dy: -defaultAcceleration)
            }
        }
    }
    
    func checkHorsePosition() {
        let horseWidth = horse.size.width
        if horse.position.y+horseWidth < 0 {
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
            scoreLabel.fontColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            if score > highestScore {
                highestScore = score
            }
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "en_US")
        let formattedScore = numberFormatter.string(from: NSNumber(value: score))
        scoreLabel.text = "Score: " + (formattedScore ?? "0")
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
        if Int.random(in: 1...35) == 1 {
            platform.texture = SKTexture(imageNamed: "duck")
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.duck
        }
        else if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "strapOfDollars" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
            if direction == "Left" {
                platform.position.x = 0
                animate(platform: platform, isLeft: true)
            }
            else {
                platform.position.x = frame.size.width
                animate(platform: platform, isLeft: false)
            }
        }
        else if Int.random(in: 1...5) == 1 {
            platform.texture = SKTexture(imageNamed: "dollarWithHole" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.dollarWithHoleCategory
        }
        else {
            platform.texture = SKTexture(imageNamed: "dollar" + direction)
            updateSizeOf(platform: platform)
            platform.physicsBody?.categoryBitMask = PhysicsCategories.platformCategory
        }
        
        platform.position.y = frame.size.height + platform.frame.size.height/2 + platform.position.y
    }
    
    func updateSizeOf(platform: SKSpriteNode) {
        if let textureSize = platform.texture?.size() {
            platform.size = CGSize(width: textureSize.width, height: textureSize.height)
            platform.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platform.size.width, height: platform.size.height))
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameStarted {
            horse.physicsBody?.velocity.dy = frame.size.height*1.2 - horse.position.y
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
                else if contactMask == PhysicsCategories.horseCategory | PhysicsCategories.dollarWithHoleCategory {
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
                    horse.physicsBody?.velocity.dy = 10
                    isSuperJumpOn = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        self.isSuperJumpOn = false
                        self.superJumpCounter = 0
                    }
                }
            }
        }
    }
}
