//
//  SettingsTableViewController.swift
//  PrehistoricBreakout
//
//  Created by Neían on 28.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {


        @IBOutlet weak var gravitySlider: UISlider! {
            didSet {
                let gravityValue = Float(UserSettings.sharedInstance.gravity)
                gravitySlider.value = gravityValue
                gravityLabel.text = String(format: "%.2f", gravityValue)
            }
        }
        @IBOutlet weak var gravityLabel: UILabel!
        @IBAction func changeGravity(sender: UISlider) {
            let gravityValue = CGFloat(sender.value)
            UserSettings.sharedInstance.gravity = gravityValue
            gravityLabel.text = String(format: "%.2f", gravityValue)
            NSNotificationCenter.defaultCenter().postNotificationName("BreakoutViewControllerUpdateSettings", object: nil)
        }
        
        // Elasticity
        @IBOutlet weak var elasticitySlider: UISlider! {
            didSet {
                let elasticityValue = Float(UserSettings.sharedInstance.elasticity)
                elasticitySlider.value = elasticityValue
                elasticityLabel.text = String(format: "%.2f", elasticityValue)
            }
        }
        @IBOutlet weak var elasticityLabel: UILabel!
        @IBAction func changeElasticity(sender: UISlider) {
            let elasticityValue = CGFloat(sender.value)
            UserSettings.sharedInstance.elasticity = elasticityValue
            elasticityLabel.text = String(format: "%.2f", elasticityValue)
            NSNotificationCenter.defaultCenter().postNotificationName("BreakoutViewControllerUpdateSettings", object: nil)
        }
        
        // Number of balls
        @IBOutlet weak var numberOfBallsSegmentedControl: UISegmentedControl! {
            didSet {
                let numberOfBouncingBalls = UserSettings.sharedInstance.numberOfBalls
                numberOfBallsSegmentedControl.selectedSegmentIndex = numberOfBouncingBalls - 1
            }
        }
        @IBAction func changeNumberOfBalls(sender: UISegmentedControl) {
            UserSettings.sharedInstance.numberOfBalls = sender.selectedSegmentIndex + 1
        }
        
        // Number of total bricks
        @IBOutlet weak var numberOfTotalBricksStepper: UIStepper! {
            didSet {
                let numberOfTotalBricks = UserSettings.sharedInstance.numberOfTotalBricks
                numberOfTotalBricksStepper.value = Double(numberOfTotalBricks)
                numberOfTotalBricksLabel.text = "\(numberOfTotalBricks)"
            }
        }
        @IBOutlet weak var numberOfTotalBricksLabel: UILabel!
        @IBAction func changeNumberOfTotalBricks(sender: UIStepper) {
            let numberOfTotalBricks = Int(sender.value)
            UserSettings.sharedInstance.numberOfTotalBricks = numberOfTotalBricks
            numberOfTotalBricksLabel.text = "\(numberOfTotalBricks)"
            
            if numberOfTotalBricks < UserSettings.sharedInstance.numberOfSpecialBricks {
                UserSettings.sharedInstance.numberOfSpecialBricks = numberOfTotalBricks
                numberOfSpecialBricksStepper.value = Double(numberOfTotalBricks)
                numberOfSpecialBricksLabel.text = "\(numberOfTotalBricks)"
            }
            numberOfSpecialBricksStepper.maximumValue = Double(numberOfTotalBricks)
        }
        
        // Number of special bricks
        @IBOutlet weak var numberOfSpecialBricksStepper: UIStepper! {
            didSet {
                numberOfSpecialBricksStepper.maximumValue = Double(UserSettings.sharedInstance.numberOfTotalBricks)
                
                let numberOfSpecialBricks = UserSettings.sharedInstance.numberOfSpecialBricks
                numberOfSpecialBricksStepper.value = Double(numberOfSpecialBricks)
                numberOfSpecialBricksLabel.text = "\(numberOfSpecialBricks)"
            }
        }
        @IBOutlet weak var numberOfSpecialBricksLabel: UILabel!
        @IBAction func changeNumberOfSpecialBricks(sender: UIStepper) {
            let numberOfSpecialBricks = Int(sender.value)
            UserSettings.sharedInstance.numberOfSpecialBricks = numberOfSpecialBricks
            numberOfSpecialBricksLabel.text = "\(numberOfSpecialBricks)"
        }
        
        // Special bricks
        @IBOutlet weak var brickSmallerPaddleSwitch: UISwitch! {
            didSet {
                brickSmallerPaddleSwitch.on = UserSettings.sharedInstance.specialBrickSmallerPaddleEnabled
            }
        }
        @IBOutlet weak var brickLargerPaddleSwitch: UISwitch! {
            didSet {
                brickLargerPaddleSwitch.on = UserSettings.sharedInstance.specialBrickLargerPaddleEnabled
            }
        }
        @IBOutlet weak var brickAddBallSwitch: UISwitch! {
            didSet {
                brickAddBallSwitch.on = UserSettings.sharedInstance.specialBrickAddBallEnabled
            }
        }
        @IBOutlet weak var brickHardSwitch: UISwitch! {
            didSet {
                brickHardSwitch.on = UserSettings.sharedInstance.specialBrickHardEnabled
            }
        }
        
        @IBAction func toggleBrickSmallerPaddle(sender: UISwitch) {
            UserSettings.sharedInstance.specialBrickSmallerPaddleEnabled = sender.on
        }
        
        @IBAction func toggleBrickLargerPaddle(sender: UISwitch) {
            UserSettings.sharedInstance.specialBrickLargerPaddleEnabled = sender.on
        }
        
        @IBAction func toggleBrickAddBall(sender: UISwitch) {
            UserSettings.sharedInstance.specialBrickAddBallEnabled = sender.on
        }
        
        @IBAction func toggleBrickHard(sender: UISwitch) {
            UserSettings.sharedInstance.specialBrickHardEnabled = sender.on
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
        }
}

