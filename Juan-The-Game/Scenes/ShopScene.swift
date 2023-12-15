import SpriteKit

class ShopScene: SKScene {
    
    var selectedHorseName: String = ""
    
    var coinsCollected: Int = 0 {
        didSet {
            UserDefaults.standard.set(coinsCollected, forKey: "CoinsCollected")
            updateCoinsLabel()
        }
    }
    
    var purchasedHorses: [String: Bool] = [:] {
        didSet {
            UserDefaults.standard.set(purchasedHorses, forKey: "PurchasedHorses")
        }
    }
    let purchasedHorsesKey = "PurchasedHorses"
    
    let coinsKey = "CoinsCollected"
    var coinLabel = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
    
    override func didMove(to view: SKView) {
        
        let backgroundImage = SKSpriteNode(imageNamed: "bgshop")
        backgroundImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundImage.size = size
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
        
        displayTotalCoins()
        setupUI()
        addHorseNodes()
        addBackButton()
        
        // Retrieve purchased horses from UserDefaults
        if let savedPurchasedHorses = UserDefaults.standard.dictionary(forKey: purchasedHorsesKey) as? [String: Bool] {
            purchasedHorses = savedPurchasedHorses
        } else {
            purchasedHorses = [:] // Initialize if not found
        }
        
        // Update UI for purchased horses
        updateUIForPurchasedHorses()
    }
    
    func updateUIForPurchasedHorses() {
        for child in children {
            if let horseNode = child as? SKSpriteNode, let horseName = horseNode.name, let isPurchased = purchasedHorses[horseName], isPurchased {
                // Check if the select button exists for the purchased horse
                if child.childNode(withName: "\(horseName)_selectButton") == nil {
                    // Add the select button if it doesn't exist
                    addSelectButtonForPurchasedHorse(horseName: horseName, at: horseNode.position)
                }
            }
        }
    }
    
    func addSelectButtonForPurchasedHorse(horseName: String, at position: CGPoint) {
        let selectButton = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
        selectButton.text = "Select"
        selectButton.fontSize = 16
        selectButton.fontColor = SKColor.green
        selectButton.position = CGPoint(x: position.x, y: position.y - 80)
        selectButton.name = "\(horseName)_selectButton"
        addChild(selectButton)
    }
    
    func addBackButton() {
        let backButton = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
        backButton.text = "Back to Menu"
        backButton.fontSize = 20
        backButton.fontColor = .white
        backButton.position = CGPoint(x: frame.midX, y: frame.minY + 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    func transitionToMenuScene() {
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = self.scaleMode
        view?.presentScene(menuScene, transition: .fade(withDuration: 0.5))
    }
    
    func displayTotalCoins() {
        if let totalCoins = UserDefaults.standard.value(forKey: coinsKey) as? Int {
            coinsCollected = totalCoins
            print("Total coins retrieved: \(totalCoins)")
        }
    }
    
    func updateCoinsLabel() {
        coinLabel.text = "Coins: \(coinsCollected)"
    }
    
    func setupUI() {
        coinLabel.fontSize = 24
        coinLabel.fontColor = SKColor.white
        coinLabel.horizontalAlignmentMode = .center
        coinLabel.verticalAlignmentMode = .center
        coinLabel.position = CGPoint(x: frame.width - 100, y: frame.height - 70)
        coinLabel.zPosition = 1
        addChild(coinLabel)
    }
    
    func addHorseNodes() {
        // Add the four horse nodes with different prices
        addHorseNode(name: "horse", price: 0, position: CGPoint(x: frame.midX, y: frame.midY - 200))
        addHorseNode(name: "black_juan", price: 15, position: CGPoint(x: frame.maxX/3, y: frame.maxY/1.5))
        addHorseNode(name: "white_juan", price: 50, position: CGPoint(x: frame.maxX/3*2, y: frame.maxY/1.5))
        addHorseNode(name: "spotted_juan", price: 100, position: CGPoint(x: frame.maxX/3, y: frame.maxY/2))
        addHorseNode(name: "golden_juan", price: 200, position: CGPoint(x: frame.maxX/3*2, y: frame.maxY/2))
    }
    
    func addHorseNode(name: String, price: Int, position: CGPoint) {
        let horseNode = SKSpriteNode(imageNamed: name)
        horseNode.name = name
        horseNode.position = position
        addChild(horseNode)
        
        let priceLabel = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
        priceLabel.text = "\(price) coins"
        priceLabel.fontSize = 16
        priceLabel.fontColor = SKColor.white
        priceLabel.position = CGPoint(x: position.x, y: position.y - 60)
        addChild(priceLabel)
        
        if let isPurchased = purchasedHorses[name], isPurchased {
            addSelectButtonForPurchasedHorse(horseName: name, at: position)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtTouch = nodes(at: location)
            
            for node in nodesAtTouch {
                if let nodeName = node.name, let price = getPriceForHorse(name: nodeName)  {
                    handleHorseInteraction(horsePrice: price, horseName: nodeName)
                    break
                }
                if let nodeName = node.name, nodeName.hasSuffix("_selectButton") {
                    handleSelectButtonTap(selectedButton: node)
                    break
                }
            }
        }
    }
    
    func handleSelectButtonTap(selectedButton: SKNode) {
        if let horseName = selectedButton.name?.replacingOccurrences(of: "_selectButton", with: "") {
            selectedHorseName = horseName // Set selected horse
            UserDefaults.standard.set(horseName, forKey: "SelectedHorse")
            print("Selected \(horseName) for gameplay")
            
            // Transition to the Game Scene
            transitionToGameScene(with: horseName)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "backButton" {
                transitionToMenuScene()
            }
            // Handle other touches if needed
        }
    }
    
    func handleHorseInteraction(horsePrice: Int, horseName: String) {
        print("Tapped on a horse costing \(horsePrice) coins")
        
        if let isPurchased = purchasedHorses[horseName], isPurchased {
            if horseName == selectedHorseName {
                print("Selected \(horseName) for gameplay")
                // Transition to the Game Scene
                transitionToGameScene(with: horseName)
            } else {
                transitionToGameScene(with: horseName)
            }
        } else {
            if coinsCollected >= horsePrice {
                coinsCollected -= horsePrice
                purchasedHorses[horseName] = true
                UserDefaults.standard.set(purchasedHorses, forKey: purchasedHorsesKey) // Update purchased horses in UserDefaults
                print("Remaining coins after purchase: \(coinsCollected)")
                print("Purchased \(horseName)")
                
                // Update the UI after purchase
                updateUIAfterPurchase()
            } else {
                print("Not enough coins to buy this horse")
                let errorMessage1 = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
                errorMessage1.text = "You don't have"
                errorMessage1.fontSize = 25
                errorMessage1.fontColor = SKColor.red
                errorMessage1.position = CGPoint(x: frame.midX, y: frame.maxY-150)
                addChild(errorMessage1)
                let errorMessage2 = SKLabelNode(fontNamed: "PixelFJ8pt1Normal")
                errorMessage2.text = "enough coins"
                errorMessage2.fontSize = 25
                errorMessage2.fontColor = SKColor.red
                errorMessage2.position = CGPoint(x: frame.midX, y: frame.maxY-180)
                addChild(errorMessage2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    errorMessage1.removeFromParent()
                    errorMessage2.removeFromParent()
                }
            }
        }
    }
    
    
    func transitionToGameScene(with horseName: String) {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        gameScene.selectedHorse = horseName // Pass the selected horse
        view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
    }
    
    func updateUIAfterPurchase() {
        updateCoinsLabel()
        // Update the purchased horses and then re-add horse nodes to update "Select" buttons
        if let savedPurchasedHorses = UserDefaults.standard.dictionary(forKey: purchasedHorsesKey) as? [String: Bool] {
            purchasedHorses = savedPurchasedHorses
        }
        removeAllHorseNodes()
        addHorseNodes()
    }
    
    func removeAllHorseNodes() {
        // Remove all child nodes that are horse nodes
        let horseNodes = children.filter { $0.name != nil && $0.name!.hasSuffix("_selectButton") }
        horseNodes.forEach { $0.removeFromParent() }
    }
    
    func getPriceForHorse(name: String) -> Int? {
        switch name {
        case "horse": return 0
        case "black_juan": return 15
        case "white_juan": return 50
        case "spotted_juan": return 100
        case "golden_juan": return 200
        default: return nil
        }
    }
}
