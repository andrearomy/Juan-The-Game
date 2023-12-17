//
//  GameViewController.swift
//  Juan-The-Game
//
//  Created by Andrea Romano on 05/12/23.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let menuScene = MenuScene(size: view.bounds.size)
            //            let menuScene = GameScene_editBg(size: view.bouds.size)
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
