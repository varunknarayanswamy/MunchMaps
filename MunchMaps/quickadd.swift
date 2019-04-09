//
//  quickadd.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/4/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import CoreLocation

class quickadd: UIViewController {

    @IBOutlet weak var add1: UIButton!
    @IBOutlet weak var add2: UIButton!
    @IBOutlet weak var add3: UIButton!
    @IBOutlet weak var add4: UIButton!
    @IBOutlet weak var add5: UIButton!
    @IBOutlet weak var add6: UIButton!
    
    
    
    var Array6 = [Search.Restaurant]()
    override func viewDidLoad() {
        super.viewDidLoad()
        addUnknown()

        // Do any additional setup after loading the view.
    }
    func addUnknown()
    {
        var ind = 1
        for i in Search.GlobalVariables.restaurantResults
        {
            if((i.saved == false) && (ind<7))
            {
                switch ind {
                case 1:
                    add1.setTitle(i.name, for: .normal)
                    add1.titleLabel?.adjustsFontSizeToFitWidth = true
                case 2:
                    add2.setTitle(i.name, for: .normal)
                    add2.titleLabel?.adjustsFontSizeToFitWidth = true
                case 3:
                    add3.setTitle(i.name, for: .normal)
                    add3.titleLabel?.adjustsFontSizeToFitWidth = true
                case 4:
                    add4.setTitle(i.name, for: .normal)
                    add4.titleLabel?.adjustsFontSizeToFitWidth = true
                case 5:
                    add5.setTitle(i.name, for: .normal)
                    add5.titleLabel?.adjustsFontSizeToFitWidth = true
                case 6:
                    add6.setTitle(i.name, for: .normal)
                    add6.titleLabel?.adjustsFontSizeToFitWidth = true
                ind = ind + 1
                default:
                    break
                }
                ind = ind + 1
                Array6.append(i)
            }
        }
        
    }
    
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        let restname = sender.titleLabel?.text
        let savedRestset = removeRest(restname: restname!)
        let savedRest = savedRestset.0
        let savedNum = savedRestset.1
        Search.GlobalVariables.savedRest.append(savedRest)
        let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == savedRest.address})
        Search.GlobalVariables.restaurantResults[ind!].saved = true
        let newRest = Readd(num: savedNum)
        sender.setTitle(newRest.name, for: .normal)
        sender.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func removeRest(restname: String) -> (Search.Restaurant, Int)
    {
        var returnRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
        var indexNum = 0
        for i in 0..<Array6.count
        {
            if (Array6[i].name == restname)
            {
                returnRest = Array6[i]
                indexNum = i
                Array6.remove(at: i)
                break
            }
        }
        return (returnRest, indexNum)
    }
    
    func Readd(num: Int)->Search.Restaurant
    {
        var returnRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
        for i in Search.GlobalVariables.restaurantResults
        {
            var works = true
            if (i.saved == false)
            {
                for x in Array6
                {
                    if (x === i)
                    {
                       works = false
                       break
                    }
                }
                if (works == true)
                {
                    returnRest = i
                    Array6.append(returnRest)
                    break
                }
            }
        }
        return returnRest
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
