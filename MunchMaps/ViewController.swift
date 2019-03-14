//
//  ViewController.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/5/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import Networking

class Search: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var Table_of_Places: UITableView!
    
    let LocationMan = CLLocationManager()
    var loccord = CLLocationCoordinate2D()
    
    class Restaurant
    {
        let name: String
        let address: String
        
        init(name: String, address: String)
        {
            self.name = name
            self.address = address
        }
    }
    
    var restaurantResults = [Restaurant]()
    var filteredResults = [Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        check_location_privacy()
        InitialArray()
        setupSearchBar()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupLocationManager()
    {
        LocationMan.delegate = self
        LocationMan.desiredAccuracy = kCLLocationAccuracyBest
        if let location = LocationMan.location?.coordinate
        {
            loccord = location
            print(location.latitude)
        }
        return
    }
    func check_location_privacy()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            checklocationAuth()
            setupLocationManager()
        }
        else
        {
            print("We need a location first")
        }
    }
    private func setupSearchBar()
    {
        SearchBar.delegate = self
        
    }
    func checklocationAuth()
    {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            break
        case .denied:
            break
            //need to tell them where they can later do this
        case .notDetermined:
            LocationMan.requestWhenInUseAuthorization()
        case .restricted:
            //let them know they can't use this
            break
        case .authorizedAlways:
            break
        }
    }
    
    func InitialArray() {
        print("In initial Array")
        let latString = String(loccord.latitude)
        let lonString = String(loccord.longitude)
        let network = Networking(baseURL: create_search_url(lat: latString, long: lonString, radius: "1700")!)
        network.headerFields = ["user-key": "b9027ccfdfaa41da59bf38701cd49889"]
            
        network.get("/get")
        {
            result in switch(result)
            {
            case .success(let zomato):
                print("success")
                let jsonval = zomato.dictionaryBody
                var data = jsonval["restaurants"] as! NSArray
                for i in data
                {
                    let restdata = i as! NSDictionary
                    var restDict = (restdata.value(forKey: "restaurant")) as! NSDictionary
                    var name = restDict.value(forKey: "name")
                    var a = restDict.value(forKey: "location")! as! NSDictionary
                    let feedprint = String(describing: name) + ":" + String(describing: a.value(forKey: "address")!)
                    let namestringfull = String(describing: name)
                    let namestringcut1 = String(namestringfull.suffix(namestringfull.count-9))
                    let namestring = String(namestringcut1.prefix(namestringcut1.count-1))
                    let location = String(describing: a.value(forKey: "address")!)
                    print(location)
                    self.restaurantResults.append(Restaurant(name: namestring, address: location))
                    self.filteredResults = self.restaurantResults
                }
                self.Table_of_Places.reloadData()
                print("out1")
            case .failure(_):
                print("error")
            }
            print("out2")
        }
        print("out3")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableClass else {return UITableViewCell()}
        cell.restname.text = filteredResults[indexPath.row].name
        cell.address.text = filteredResults[indexPath.row].address
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredResults = restaurantResults
            Table_of_Places.reloadData()
            return
        }
        
        filteredResults = restaurantResults.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
        Table_of_Places.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    


//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }


}
extension Search: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //hello
    }
}
    



