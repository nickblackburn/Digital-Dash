//
//  ResultsTableViewCell.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/22/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit

class ExerciseIDViewCell: UITableViewCell {
    
    @IBOutlet weak var ExerciseIDLabel: UILabel!
    @IBOutlet weak var ExerciseIDSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Set selected for a table view cell
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
