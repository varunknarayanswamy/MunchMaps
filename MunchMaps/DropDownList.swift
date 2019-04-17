//
//  DropDownList.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/14/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class DropDownList: UIViewController {
    
    var returnString: String = ""
    var delegate: DropDownListDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saved(_ sender: Any) {
        returnString = "saved"
        self.view.removeFromSuperview()
        delegate?.setStatus(status: "saved")
    }
    
    @IBAction func future(_ sender: Any) {
        returnString = "future"
        self.view.removeFromSuperview()
        delegate?.setStatus(status: "future")
    }
    
     @IBAction func cancel(_ sender: Any) {
        returnString = "unsaved"
        self.view.removeFromSuperview()
        delegate?.setStatus(status: "unsaved")
     }
    
     /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol DropDownListDelegate {
    func setStatus(status: String)
}
