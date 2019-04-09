//
//  randomRestaurant.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/6/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class randomRestaurant: UIViewController {
    
    var currentRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
    var pastRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
     var nextRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
    let locationManager = CLLocationManager()
    var unsavedRest = [Search.Restaurant]()
    var currentIndex = 0
    @IBOutlet weak var restTitle: UILabel!
    @IBOutlet weak var added: UIButton!
    let regionmeters: Double = 10000
    @IBOutlet weak var mapview: MKMapView!
    
    override func viewDidLoad() {
        //initializeData()
        initialize()
        PageSetup()
        location_setup()
        getdirections()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*func initializeData()
    {
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

    }*/
    
    func initialize()
    {
        for i in Search.GlobalVariables.restaurantResults
        {
            if (i.saved == false)
            {
                unsavedRest.append(i)
            }
        }
        unsavedRest.shuffle()
        currentIndex = unsavedRest.count/2
        print(currentIndex)
        currentRest = unsavedRest[currentIndex]
        pastRest = unsavedRest[currentIndex-1]
        nextRest = unsavedRest[currentIndex+1]
    }
    
    func PageSetup()
    {
        restTitle.text = currentRest.name
        added.setTitle("add", for: .normal)
        added.setTitleColor(.blue, for: .normal)
    }
    
    
    @IBAction func forwardRest(_ sender: Any) {
    if (currentIndex == unsavedRest.count-1)
        {
            currentIndex = 0
        }
        else
        {
            currentIndex = currentIndex + 1
        }
        currentRest = unsavedRest[currentIndex]
        pastRest = unsavedRest[currentIndex-1]
        if (currentIndex == unsavedRest.count-1)
        {
            nextRest = unsavedRest[0]
        }
        else
        {
            nextRest = unsavedRest[currentIndex+1]
        }
        let overlay = mapview.overlays
        mapview.removeOverlays(overlay)
        PageSetup()
        location_setup()
        getdirections()
    }
    
    
    @IBAction func prevRest(_ sender: Any) {
        if (currentIndex == 0)
        {
            currentIndex = unsavedRest.count-1
        }
        else
        {
            currentIndex = currentIndex - 1
        }
        currentRest = unsavedRest[currentIndex]
        nextRest = unsavedRest[currentIndex+1]
        if (currentIndex == 0)
        {
            pastRest = unsavedRest[unsavedRest.count-1]
        }
        else
        {
            nextRest = unsavedRest[currentIndex-1]
        }
        let overlay = mapview.overlays
        mapview.removeOverlays(overlay)
        PageSetup()
        location_setup()
        getdirections()
    }
    
    
    @IBAction func Add(_ sender: Any) {
    if (currentRest.saved == false)
        {
            Search.GlobalVariables.savedRest.append(currentRest)
            added.setTitleColor(.green, for: .normal)
            added.setTitle("Saved", for: .normal)
            let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
            Search.GlobalVariables.restaurantResults[ind!].saved = true
            for i in Search.GlobalVariables.savedRest
            {
                print(i.name)
            }
        }
        else
        {
            Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != currentRest.name}
            added.setTitleColor(.blue, for: .normal)
            added.setTitle("Add", for: .normal)
            let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
            Search.GlobalVariables.restaurantResults[ind!].saved = false
            for i in Search.GlobalVariables.savedRest
            {
                print(i.name)
            }
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
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //let them know they can't use this
            break
        case .authorizedAlways:
            break
        }
    }
    
    func location_setup()
    {
        locationManager.delegate = self
        mapview.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapview.showsUserLocation = true
        centerlocation()
        locationManager.startUpdatingLocation()
    }
    
    func centerlocation()
    {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionmeters, longitudinalMeters: regionmeters)
            mapview.setRegion(region, animated: true)
        }
    }
    
    func getdirections()
    {
        guard let location = locationManager.location?.coordinate else
        {return}
        
        print(location.latitude)
        let request = requestfunc(from: location)
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (response, error) in //explanation
            guard let response = response else {return}
            for route in response.routes {
                print("added response")
                self.mapview.addOverlay(route.polyline)
                self.mapview.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func requestfunc(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request
    {
        let startLocation = MKPlacemark(coordinate: coordinate)
        print(currentRest.Latlocation.latitude)
        print(startLocation.coordinate)
        let destination = MKPlacemark(coordinate: currentRest.Latlocation)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = false
        return request
    }

}

extension randomRestaurant: CLLocationManagerDelegate {
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
     guard let location = locations.last else {return}
     let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
     let region = MKCoordinateRegion(center: center, latitudinalMeters: regionmeters, longitudinalMeters: regionmeters)
     mapview.setRegion(region, animated: true)
     }*/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checklocationAuth()
    }
}
extension randomRestaurant: MKMapViewDelegate {
    /*func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
     let center = getCenterOfMap(for: mapview)
     guard let previous = self.previousLocation else {return}
     guard center.distance(from: previous) > 50 else {return}
     self.previousLocation = center
     }*/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        print("rendered")
        return renderer
    }
}
