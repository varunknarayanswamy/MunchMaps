//
//  saved_future.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/25/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class saved_future: UIViewController {

    @IBAction func saved_list(_ sender: Any) {
        performSegue(withIdentifier: "saved_list", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
