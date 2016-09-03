//
//  SettingsTableViewController.swift
//  PrehistoricBreakout
//
//  Created by Neían on 28.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var howManyRows: UIStepper!
    @IBOutlet weak var howManyRowsLabel: UILabel!
    @IBOutlet weak var howManyColumns: UIStepper!
    @IBOutlet weak var howManyColumnsLabel: UILabel!
    
    @IBOutlet weak var ballSize: UISegmentedControl!
    @IBOutlet weak var ballAngle: UISlider!
    struct BallSize {
        static var First = (SegmentIndex: 0, Size: CGFloat(15.0))
        static var Second = (SegmentIndex: 1, Size: CGFloat(25.0))
        static var Third = (SegmentIndex: 2, Size: CGFloat(40.0))
    }
    
    @IBOutlet weak var playAfterFinished: UISwitch!
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        howManyRows.value = Double(AppDelegate.Settings.Brick.Rows)
        howManyRowsLabel.text = "\(AppDelegate.Settings.Brick.Rows)"
        howManyColumns.value = Double(AppDelegate.Settings.Brick.Columns)
        howManyColumnsLabel.text = "\(AppDelegate.Settings.Brick.Columns)"
        
        if AppDelegate.Settings.Ball.Size <= BallSize.First.Size {
            ballSize.selectedSegmentIndex = BallSize.First.SegmentIndex
        } else if BallSize.Third.Size <= AppDelegate.Settings.Ball.Size {
            ballSize.selectedSegmentIndex = BallSize.Third.SegmentIndex
        } else {
            ballSize.selectedSegmentIndex = BallSize.Second.SegmentIndex
        }
        
        playAfterFinished.on = AppDelegate.Settings.Game.ContinueAfterGameOver
    }
    
    
    @IBAction func howManyRows(sender: UIStepper) {
        let numRows = Int(sender.value)
        howManyRowsLabel.text = "\(numRows)";
        AppDelegate.Settings.Brick.Rows = numRows;
    }
    
    @IBAction func howManyColumns(sender: UIStepper) {
        let numColumns = Int(sender.value)
        howManyColumnsLabel.text = "\(numColumns)";
        AppDelegate.Settings.Brick.Columns = numColumns;
    }
    
    @IBAction func ballSize(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case BallSize.First.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSize.First.Size
        case BallSize.Second.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSize.Second.Size
        case BallSize.Third.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSize.Third.Size
        default:
            AppDelegate.Settings.Ball.Size = BallSize.Second.Size
        }
    }
    
    @IBAction func ballAngle(sender: UISlider) {
        AppDelegate.Settings.Ball.StartSpreadAngle = CGFloat(sender.value)
    }
    
    @IBAction func playAfterFinished(sender: UISwitch) {
        AppDelegate.Settings.Game.ContinueAfterGameOver = sender.on
    }
    
}

