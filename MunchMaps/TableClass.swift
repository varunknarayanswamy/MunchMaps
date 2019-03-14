//
//  TableClass.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/12/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class TableClass: UITableViewCell {

    @IBOutlet weak var restname: UILabel!
    @IBOutlet weak var address: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
