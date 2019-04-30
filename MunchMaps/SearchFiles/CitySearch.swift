//
//  CitySearch.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/8/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import Networking
import CoreLocation

class CitySearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterTabDelegate{
    
    @IBOutlet weak var CitySearch: UISearchBar!
    @IBOutlet weak var CityRestTable: UITableView!
    var City_info = location_or_city.City(name: "", id: "", country: "", state: "")
    
    var filteredArray = [Search.Restaurant]()
    override func viewDidLoad() {
        InitialArray()
        setupSearchBar()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func InitialArray() {
        //let network = Networking(baseURL: create_search_url(lat: latString, long: lonString, radius: "50000")!)
        Search.GlobalVariables.restaurantResults.removeAll()
        var start = 0
        let count = 20
        while (start<100)
        {
            let start_string = "&start=" + String(start)
            let network = Networking(baseURL: "https://developers.zomato.com/api/v2.1/search?entity_id=" + City_info.id + "&entity_type=city" + start_string + "&count=20&sort=cost&order=asc")
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
                        let locationany = a.value(forKey: "address")
                        let namestring = self.cropSearch(word: name as Any)
                        let latDouble = Double(self.cropSearch(word: lat as Any))
                        let longDouble = Double(self.cropSearch(word: long as Any))
                        let CuisineString = self.cropSearch(word: cuisine as Any)
                        let location = self.cropSearch(word: locationany as Any)
                        let cuisineArr = CuisineString.components(separatedBy: ", ")
                        let CLLocation = CLLocationCoordinate2D(latitude: latDouble!, longitude: longDouble!)
                        Search.GlobalVariables.restaurantResults.append(Search.Restaurant(name: namestring, address: location, Latlocation: CLLocation, saved: "unsaved", cuisine: cuisineArr))
                        Search.GlobalVariables.CuisineResults = Search.GlobalVariables.restaurantResults
                        self.filteredArray = Search.GlobalVariables.restaurantResults
                    }
                    self.CityRestTable.reloadData()
                case .failure(_):
                    print("error")
                }
            }
            start = start + 20
        }
    }
    
    func cropSearch(word: Any)-> String
    {
        let StringWord = String(describing: word)
        let StringSuffix = String(StringWord.suffix(StringWord.count-9))
        let StringPrefix = String(StringSuffix.prefix(StringSuffix.count-1))
        return StringPrefix
    }
    
    private func setupSearchBar()
    {
        CitySearch.delegate = self
        CitySearch.showsBookmarkButton = true
        CitySearch.setImage(UIImage(named: "Filterbutton"), for: .bookmark, state: .normal)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TableClass else {return UITableViewCell()}
        cell.restname.text = filteredArray[indexPath.row].name
        cell.address.text = filteredArray[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "CityMove", sender: filteredArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! RestaurantPage
        svc.rest_info = sender as! Search.Restaurant
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredArray = Search.GlobalVariables.CuisineResults
            CityRestTable.reloadData()
            return
        }
        
        filteredArray = Search.GlobalVariables.CuisineResults.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
        CityRestTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterMenu") as! FilterTab
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.delegate = self
        if (CitySearch.isFirstResponder)
        {
            CitySearch.resignFirstResponder()
        }
    }
    
    func popupDidDisappear() {
        if (FilterTab.CuisineGlobal.SavedCuisine.count == 0 && FilterTab.CuisineGlobal.removeCuisine.count == 0)
        {
            print("empty?")
            Search.GlobalVariables.CuisineResults = Search.GlobalVariables.restaurantResults
            filteredArray = Search.GlobalVariables.CuisineResults
            CityRestTable.reloadData()
        }
        else if (FilterTab.CuisineGlobal.SavedCuisine.count == 0)
        {
            Search.GlobalVariables.CuisineResults = Search.GlobalVariables.restaurantResults
            for i in Search.GlobalVariables.CuisineResults
            {
                outerloop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            Search.GlobalVariables.CuisineResults = Search.GlobalVariables.CuisineResults.filter {$0.name != i.name}
                            break outerloop
                        }
                    }
                }
            }
            filteredArray = Search.GlobalVariables.CuisineResults
            CityRestTable.reloadData()
        }
        else
        {
            
            print(FilterTab.CuisineGlobal.SavedCuisine.count)
            Search.GlobalVariables.CuisineResults.removeAll()
            var CuisineString = FilterTab.CuisineGlobal.SavedCuisine[0].id
            if (FilterTab.CuisineGlobal.SavedCuisine.count > 1)
            {
                for i in 1...FilterTab.CuisineGlobal.SavedCuisine.count-1
                {
                    CuisineString = CuisineString + "%2C"+FilterTab.CuisineGlobal.SavedCuisine[i].id
                }
            }
            let sortString = "&sort=" + FilterTab.CuisineGlobal.sortby
            let orderString = "&order=" + FilterTab.CuisineGlobal.order
            print(orderString)
            let network = Networking(baseURL: "https://developers.zomato.com/api/v2.1/search?entity_id=" + City_info.id + "&cuisines=" + CuisineString + "&entity_type=city"+sortString+orderString)
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
                        Search.GlobalVariables.CuisineResults.append(Search.Restaurant(name: namestring, address: location, Latlocation: CLLocation, saved: "unsaved", cuisine: latArr))
                        self.filteredArray = Search.GlobalVariables.CuisineResults
                    }
                    self.CityRestTable.reloadData()
                case .failure(_):
                    print("error")
                }
            }
            for i in Search.GlobalVariables.CuisineResults
            {
                outerLoop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            Search.GlobalVariables.CuisineResults = Search.GlobalVariables.CuisineResults.filter {$0.name != i.name}
                            break outerLoop
                        }
                    }
                }
            }
            filteredArray = Search.GlobalVariables.CuisineResults
            CityRestTable.reloadData()
        }
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
