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

class Search: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterTabDelegate {

    var SearchController = UISearchController()
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var Table_of_Places: UITableView!
    
    let LocationMan = CLLocationManager()
    var loccord = CLLocationCoordinate2D()
    
    struct GlobalVariables {
        static var savedRest = [Restaurant]()
        static var futureRest = [Restaurant]()
        static var restaurantResults = [Restaurant]()
    }
    
    internal class Restaurant
    {
        let name: String
        let address: String
        let Latlocation: CLLocationCoordinate2D
        var saved: String
        var cuisine = [String]()
        
        init(name: String, address: String, Latlocation: CLLocationCoordinate2D, saved: String, cuisine: [String])
        {
            self.name = name
            self.address = address
            self.Latlocation = Latlocation
            self.saved = saved
            self.cuisine = cuisine
        }
    }
    
    var filteredResults = [Restaurant]()
    var CuisineResults = [Restaurant]()
    
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
        SearchBar.showsBookmarkButton = true
        SearchBar.setImage(UIImage(named: "Filterbutton"), for: .bookmark, state: .normal)
        
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
                let data = jsonval["restaurants"] as! NSArray
                for i in data
                {
                    let restdata = i as! NSDictionary
                    let restDict = (restdata.value(forKey: "restaurant")) as! NSDictionary
                    let name = restDict.value(forKey: "name")
                    let a = restDict.value(forKey: "location")! as! NSDictionary
                    let cuisine = restDict.value(forKey: "cuisines")
                    let lat = a.value(forKey: "latitude")
                    let long = a.value(forKey: "longitude")
                    let address = a.value(forKey: "address")
                    let location = self.cropSearch(word: address as Any)
                    let namestring = self.cropSearch(word: name as Any)
                    let latDouble = Double(self.cropSearch(word: lat as Any))
                    let longDouble = Double(self.cropSearch(word: long as Any))
                    let CuisineString = self.cropSearch(word: cuisine as Any)
                    print(CuisineString)
                    let latArr = CuisineString.components(separatedBy: ", ")
                    let CLLocation = CLLocationCoordinate2D(latitude: latDouble!, longitude: longDouble!)
                    GlobalVariables.restaurantResults.append(Restaurant(name: namestring, address: location, Latlocation: CLLocation, saved: "unsaved", cuisine: latArr))
                    self.CuisineResults = GlobalVariables.restaurantResults
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
    
    func cropSearch(word: Any)-> String
    {
        let StringWord = String(describing: word)
        let StringSuffix = String(StringWord.suffix(StringWord.count-9))
        let StringPrefix = String(StringSuffix.prefix(StringSuffix.count-1))
        return StringPrefix
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
            filteredResults = CuisineResults
            Table_of_Places.reloadData()
            return
        }
        
        filteredResults = CuisineResults.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
        Table_of_Places.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func popupDidDisappear() {
        if (FilterTab.CuisineGlobal.SavedCuisine.count == 0 && FilterTab.CuisineGlobal.removeCuisine.count == 0)
        {
            print("empty?")
            CuisineResults = GlobalVariables.restaurantResults
            filteredResults = CuisineResults
            Table_of_Places.reloadData()
        }
        else if (FilterTab.CuisineGlobal.SavedCuisine.count == 0)
        {
            CuisineResults = GlobalVariables.restaurantResults
            for i in CuisineResults
            {
                outerloop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults = CuisineResults.filter {$0.name != i.name}
                            break outerloop
                        }
                    }
                }
            }
            filteredResults = CuisineResults
            Table_of_Places.reloadData()
        }
        else
        {
            print(FilterTab.CuisineGlobal.SavedCuisine.count)
            CuisineResults.removeAll()
            for i in GlobalVariables.restaurantResults
            {
                outerLoop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.SavedCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults.append(i)
                            break outerLoop
                        }
                    }
                }
            }
            for i in CuisineResults
            {
                outerLoop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults = CuisineResults.filter {$0.name != i.name}
                            break outerLoop
                        }
                    }
                }
            }
            filteredResults = CuisineResults
            Table_of_Places.reloadData()
        }
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
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterMenu") as! FilterTab
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.delegate = self
        if (searchBar.isFirstResponder)
        {
            searchBar.resignFirstResponder()
        }
    }
}

    



