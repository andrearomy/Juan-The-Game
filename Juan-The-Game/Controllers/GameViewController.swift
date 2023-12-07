//
//  GameViewController.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 05/12/23.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let menuScene = MenuScene(size: view.bounds.size)
//            let menuScene = GameScene_editBg(size: view.bounds.size)
            // Set the scale mode to scale to fit the window
            menuScene.scaleMode = .aspectFill
                
            // Present the scene
            view.presentScene(menuScene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
        }
    }

}
