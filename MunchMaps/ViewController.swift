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
    
    struct GlobalVariables {
        static var savedRest = [Restaurant]()
        static var restaurantResults = [Restaurant]()
    }
    
    internal class Restaurant
    {
        let name: String
        let address: String
        let Latlocation: CLLocationCoordinate2D
        var saved: Bool
        
        init(name: String, address: String, Latlocation: CLLocationCoordinate2D, saved: Bool)
        {
            self.name = name
            self.address = address
            self.Latlocation = Latlocation
            self.saved = saved
        }
    }
    
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
    
    public func InitialArray() {
        GlobalVariables.restaurantResults.removeAll()
        print("In initial Array")
        let latString = String(loccord.latitude)
        let lonString = String(loccord.longitude)
        print(latString)
        print(lonString)
        let network = Networking(baseURL: create_search_url(lat: latString, long: lonString, radius: "50000")!)
        //let network = Networking(baseURL: "https://developers.zomato.com/api/v2.1/search?entity_id=216&entity_type=city")
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
                    var lat = a.value(forKey: "latitude")
                    var long = a.value(forKey: "longitude")
                    let namestringfull = String(describing: name)
                    let namestringcut1 = String(namestringfull.suffix(namestringfull.count-9))
                    let namestring = String(namestringcut1.prefix(namestringcut1.count-1))
                    let location = String(describing: a.value(forKey: "address")!)
                    let latVal = String(describing: lat)
                    let longVal = String(describing: long)
                    print(longVal)
                    let latRemove = String(latVal.suffix(latVal.count-9))
                    let longRemove = String(longVal.suffix(longVal.count-9))
                    let latRemove2 = String(latRemove.prefix(latRemove.count-1))
                    let longRemove2 = String(longRemove.prefix(longRemove.count-1))
                    let latDouble = Double(latRemove2)
                    let longDouble = Double(longRemove2)
                    let CLLocation = CLLocationCoordinate2D(latitude: latDouble!, longitude: longDouble!)
                    print(location)
                    GlobalVariables.restaurantResults.append(Restaurant(name: namestring, address: location, Latlocation: CLLocation, saved: false))
                    self.filteredResults = GlobalVariables.restaurantResults
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "MapMove", sender: filteredResults[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! RestaurantPage
        svc.rest_info = sender as! Restaurant
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredResults = GlobalVariables.restaurantResults
            Table_of_Places.reloadData()
            return
        }
        
        filteredResults = GlobalVariables.restaurantResults.filter({Restaurant->Bool in
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
    



