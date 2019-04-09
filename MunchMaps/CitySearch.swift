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

class CitySearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
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
        let network = Networking(baseURL: "https://developers.zomato.com/api/v2.1/search?entity_id=" + City_info.id + "&entity_type=city&sort=cost&order=asc")
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
                    let restDict = (restdata.value(forKey: "restaurant")) as! NSDictionary
                    let name = restDict.value(forKey: "name")
                    let a = restDict.value(forKey: "location")! as! NSDictionary
                    let lat = a.value(forKey: "latitude")
                    let long = a.value(forKey: "longitude")
                    let namestringfull = String(describing: name)
                    let namestringcut1 = String(namestringfull.suffix(namestringfull.count-9))
                    let namestring = String(namestringcut1.prefix(namestringcut1.count-1))
                    let location = String(describing: a.value(forKey: "address")!)
                    let latVal = String(describing: lat)
                    let longVal = String(describing: long)
                    let latRemove = String(latVal.suffix(latVal.count-9))
                    let longRemove = String(longVal.suffix(longVal.count-9))
                    let latRemove2 = String(latRemove.prefix(latRemove.count-1))
                    let longRemove2 = String(longRemove.prefix(longRemove.count-1))
                    let latDouble = Double(latRemove2)
                    let longDouble = Double(longRemove2)
                    let CLLocation = CLLocationCoordinate2D(latitude: latDouble!, longitude: longDouble!)
                    print(location)
                    Search.GlobalVariables.restaurantResults.append(Search.Restaurant(name: namestring, address: location, Latlocation: CLLocation, saved: false))
                    self.filteredArray = Search.GlobalVariables.restaurantResults
                }
                self.CityRestTable.reloadData()
            case .failure(_):
                print("error")
            }
        }
    }
    
    private func setupSearchBar()
    {
        CitySearch.delegate = self
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
            filteredArray = Search.GlobalVariables.restaurantResults
            CityRestTable.reloadData()
            return
        }
        
        filteredArray = Search.GlobalVariables.restaurantResults.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
        CityRestTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
