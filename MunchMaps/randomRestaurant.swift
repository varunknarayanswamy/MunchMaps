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

class randomRestaurant: UIViewController, DropDownListDelegate {
    
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var backwardButton: UIButton!
    var oldStatus: String = ""
    var currentRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: "", cuisine: [])
    var pastRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: "", cuisine: [])
    var nextRest = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: "", cuisine: [])
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
    
    func initialize()
    {
        for i in Search.GlobalVariables.restaurantResults
        {
            if (i.saved == "unsaved")
            {
                unsavedRest.append(i)
            }
        }
        unsavedRest.shuffle()
        currentIndex = unsavedRest.count/2
        print(currentIndex)
        currentRest = unsavedRest[currentIndex]
    }
    
    func PageSetup()
    {
        restTitle.text = currentRest.name
        added.setTitle("add", for: .normal)
        added.setTitleColor(.blue, for: .normal)
        restTitle.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        added.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        forwardButton.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        backwardButton.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
        
    }
    
    
    @IBAction func forwardRest(_ sender: Any) {
        if (oldStatus != "unsaved")
        {
            unsavedRest.remove(at: currentIndex)
            if (currentIndex == unsavedRest.count)
            {
                currentIndex = 0
            }
            currentRest = unsavedRest[currentIndex]
        }
        else
        {
            if (currentIndex == unsavedRest.count-1)
            {
                currentIndex = 0
            }
            else
            {
                currentIndex = currentIndex + 1
            }
            currentRest = unsavedRest[currentIndex]
        }
        print(currentIndex)
        oldStatus = "unsaved"
        let overlay = mapview.overlays
        mapview.removeOverlays(overlay)
        PageSetup()
        location_setup()
        getdirections()
    }
    
    
    @IBAction func prevRest(_ sender: Any) {
        if (oldStatus != "unsaved")
        {
            unsavedRest.remove(at: currentIndex)
        }
        if (currentIndex == 0)
        {
            currentIndex = unsavedRest.count - 1
        }
        else
        {
            currentIndex = currentIndex-1
        }
        print(currentIndex)
        oldStatus = "unsaved"
        currentRest = unsavedRest[currentIndex]
        let overlay = mapview.overlays
        mapview.removeOverlays(overlay)
        PageSetup()
        location_setup()
        getdirections()
    }
    
    
    @IBAction func Add(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DropDown") as! DropDownList
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.delegate = self
        
    if (currentRest.saved == "unsaved")
        {
            Search.GlobalVariables.savedRest.append(currentRest)
            added.setTitle("Saved", for: .normal)
            let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
            Search.GlobalVariables.restaurantResults[ind!].saved = "saved"
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
            Search.GlobalVariables.restaurantResults[ind!].saved = "unsaved"
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
    
    func setStatus(status: String) {
        if (status == "saved")
        {
            added.backgroundColor = UIColor.init(red: 70/255, green: 255/255, blue: 146/255, alpha: 1.0)
            forwardButton.backgroundColor = UIColor.init(red: 70/255, green: 255/255, blue: 146/255, alpha: 1.0)
            backwardButton.backgroundColor = UIColor.init(red: 70/255, green: 255/255, blue: 146/255, alpha: 1.0)
            restTitle.backgroundColor = UIColor.init(red: 70/255, green: 255/255, blue: 146/255, alpha: 1.0)
            added.setTitle("Saved", for: .normal)
            if (oldStatus == "unsaved")
            {
                Search.GlobalVariables.savedRest.append(currentRest)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "saved"
            }
            if (oldStatus == "future")
            {
                Search.GlobalVariables.futureRest = Search.GlobalVariables.futureRest.filter{ $0.name != currentRest.name}
                Search.GlobalVariables.savedRest.append(currentRest)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "saved"
            }
            oldStatus = "saved"
        }
        else if (status == "future")
        {
            added.backgroundColor = UIColor.init(red: 255/255, green: 253/255, blue: 164/255, alpha: 1.0)
            restTitle.backgroundColor = UIColor.init(red: 255/255, green: 253/255, blue: 164/255, alpha: 1.0)
            forwardButton.backgroundColor = UIColor.init(red: 255/255, green: 253/255, blue: 164/255, alpha: 1.0)
            backwardButton.backgroundColor = UIColor.init(red: 255/255, green: 253/255, blue: 164/255, alpha: 1.0)
            added.setTitle("future", for: .normal)
            print(oldStatus)
            if (oldStatus == "unsaved")
            {
                print("futureunsaved")
                Search.GlobalVariables.futureRest.append(currentRest)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "future"
            }
            if (oldStatus == "saved")
            {
                Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != currentRest.name}
                Search.GlobalVariables.futureRest.append(currentRest)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "future"
            }
            oldStatus = "future"
        }
        else
        {
            added.setTitleColor(.blue, for: .normal)
            added.setTitle("add", for: .normal)
            if (oldStatus == "future")
            {
                Search.GlobalVariables.futureRest = Search.GlobalVariables.futureRest.filter{ $0.name != currentRest.name}
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "unsaved"
            }
            if (oldStatus == "saved")
            {
                Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != currentRest.name}
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == currentRest.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "unsaved"
            }
            oldStatus = "unsaved"
        }
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
