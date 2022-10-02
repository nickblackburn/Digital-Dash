//
//  CircleLabelView.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/19/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit

class CircleLabelView: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        
        // Make corners rounded
        self.layer.cornerRadius = 8
    }
}
