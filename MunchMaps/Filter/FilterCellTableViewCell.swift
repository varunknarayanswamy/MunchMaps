//
//  FilterCellTableViewCell.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/13/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class FilterCellTableViewCell: UITableViewCell {

    @IBOutlet weak var CuisineLabel: UILabel!
    @IBOutlet weak var Circle: UIImageView!
    
    var state = "unpressed"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
