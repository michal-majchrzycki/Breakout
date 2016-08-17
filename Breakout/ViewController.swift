//
//  ViewController.swift
//  Breakout
//
//  Created by Neían on 16.08.2016.
//  Copyright © 2016 Michał Majchrzycki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var startGameButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func LetsStartGame(sender: UIButton) {
        startGameButton.hidden = true
        
    }


}

