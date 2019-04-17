//
//  location_or_city.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/7/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import CoreLocation
import Networking

class location_or_city: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
   
    @IBOutlet weak var LocationButton: UIButton!
    let citySearchUrl = "https://developers.zomato.com/api/v2.1/cities?q="
    let LocationMan = CLLocationManager()
    var loccord = CLLocationCoordinate2D()
    @IBOutlet weak var CityTable: UITableView!
    @IBOutlet weak var CityTextField: UITextField!
    class City
    {
        let name: String
        let id: String
        let country: String
        let state: String
        
        init(name: String, id: String, country: String, state: String) {
            self.name = name
            self.id = id
            self.country = country
            self.state = state
        }
    }
    
    var initialCityArray = [City]()
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        check_location_privacy()
        self.CityTextField.delegate = self
        LocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        // Do any additional setup after loading the view.
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
    
    @IBAction func LocationButton(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        performSegue(withIdentifier: "locationSearch", sender: nil)
        
    }
    
    @IBAction func CityButton(_ sender: Any) {
        if (CityTextField.text == "")
        {
            print("add in city name")
        }
        else
        {
            let url = citySearchUrl + CityTextField.text!
            let network = Networking(baseURL: url)
            network.headerFields = ["user-key": "b9027ccfdfaa41da59bf38701cd49889"]
            network.get("/get")
            {
                result in switch(result)
                {
                case .success(let zomato):
                    let jsonval = zomato.dictionaryBody
                    let data = jsonval["location_suggestions"] as! NSArray
                    for i in data{
                       let citydata = i as! NSDictionary
                       
                       let cityName = (citydata.value(forKey: "name"))
                       let id = (citydata.value(forKey: "id"))
                       let country = (citydata.value(forKey: "country_id"))
                       let state = (citydata.value(forKey: "state_name"))
                       let CityNameCrop = self.cropSearch(word: cityName as Any)
                       let CityIDCrop = self.cropSearch(word: id as Any)
                       let CityCountryCrop = self.cropSearch(word: country as Any)
                       let CityStateCrop = self.cropSearch(word: state as Any)
                       self.initialCityArray.append(City(name: CityNameCrop, id: CityIDCrop, country: CityCountryCrop, state: CityStateCrop))
                    }
                    print("hello")
                    for i in self.initialCityArray
                    {
                        print(i.name)
                    }
                    self.CityTable.reloadData()
                    self.CityTextField.resignFirstResponder()
                case .failure(_):
                    print("error")
                }
            }

        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        CityTextField.resignFirstResponder()
        return true
    }
    
    func cropSearch(word: Any)-> String
    {
        let StringWord = String(describing: word)
        let StringSuffix = String(StringWord.suffix(StringWord.count-9))
        let StringPrefix = String(StringSuffix.prefix(StringSuffix.count-1))
        return StringPrefix
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return initialCityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityTableCell else {return UITableViewCell()}
        cell.CityLabel.text = initialCityArray[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tabBarController?.tabBar.isHidden = false
        print("cell found")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "City", sender: initialCityArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "City")
        {
            let svc = segue.destination as! CitySearch
            svc.City_info = sender as! City
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

extension location_or_city: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //hello
    }
}
