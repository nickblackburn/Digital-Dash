//
//  ViewController.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/18/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    // Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    // Segue from Home to Map
    @IBAction func StartTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToMap", sender: nil)
    }
    
    // Segue from Home to Results
    @IBAction func HistoryTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeToResults", sender: nil)
    }
    
    // Memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Portrait mode only
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // Does not autorotate
    override var shouldAutorotate: Bool {
        return false
    }


}

