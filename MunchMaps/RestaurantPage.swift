//
//  RestaurantPage.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/21/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RestaurantPage: UIViewController, DropDownListDelegate {
    
    var savedStatus: String = ""
    var oldStatus: String = ""
    let locationManager = CLLocationManager()
    var futureRest = [Search.Restaurant]()
    @IBOutlet weak var Add: UIButton!
    let regionmeters: Double = 10000
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var restaurant_Name: UILabel!
    var previousLocation: CLLocation?
    var rest_info = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: "", cuisine: [])
    
    override func viewDidLoad() {
        print(rest_info.saved)
        initialsetup()
        location_setup()
        getdirections()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initialsetup()
    {
        restaurant_Name.text = rest_info.name
        print(rest_info.saved)
        if (rest_info.saved == "unsaved")
        {
            Add.setTitle("add", for: .normal)
            restaurant_Name.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
            Add.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
            oldStatus = "unsaved"
        }
        else if (rest_info.saved == "saved")
        {
            Add.setTitle("saved", for: .normal)
            restaurant_Name.backgroundColor = UIColor.green
            Add.backgroundColor = UIColor.green
            oldStatus = "saved"
        }
        else
        {
            Add.setTitle("future", for: .normal)
            restaurant_Name.backgroundColor = UIColor.yellow
            Add.backgroundColor = UIColor.yellow
            oldStatus = "future"
        }
    }
    @IBAction func Add_button(_ sender: Any) {
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DropDown") as! DropDownList
            self.addChild(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
            popOverVC.delegate = self
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
        print(rest_info.Latlocation.latitude)
        print(startLocation.coordinate)
        let destination = MKPlacemark(coordinate: rest_info.Latlocation)
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
            Add.backgroundColor = UIColor.green
            restaurant_Name.backgroundColor = UIColor.green
            Add.setTitle("Saved", for: .normal)
            if (oldStatus == "unsaved")
            {
                Search.GlobalVariables.savedRest.append(rest_info)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "saved"
            }
            if (oldStatus == "future")
            {
             Search.GlobalVariables.futureRest = Search.GlobalVariables.futureRest.filter{ $0.name != rest_info.name}
             Search.GlobalVariables.savedRest.append(rest_info)
             let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
             Search.GlobalVariables.restaurantResults[ind!].saved = "saved"
            }
            oldStatus = "saved"
        }
        else if (status == "future")
        {
            Add.backgroundColor = UIColor.yellow
            restaurant_Name.backgroundColor = UIColor.yellow
            Add.setTitle("future", for: .normal)
            print(oldStatus)
            if (oldStatus == "unsaved")
            {
                print("futureunsaved")
                Search.GlobalVariables.futureRest.append(rest_info)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "future"
            }
            if (oldStatus == "saved")
            {
                print("futuresaved")
                Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != rest_info.name}
                Search.GlobalVariables.futureRest.append(rest_info)
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "future"
            }
            oldStatus = "future"
        }
        else
        {
            Add.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
            restaurant_Name.backgroundColor = UIColor.init(white: 0.8, alpha: 1)
            Add.setTitle("add", for: .normal)
            if (oldStatus == "future")
            {
                Search.GlobalVariables.futureRest = Search.GlobalVariables.futureRest.filter{ $0.name != rest_info.name}
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "unsaved"
            }
            if (oldStatus == "saved")
            {
                Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != rest_info.name}
                let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
                Search.GlobalVariables.restaurantResults[ind!].saved = "unsaved"
            }
            oldStatus = "unsaved"
        }
    }
    
    /*func getCenterOfMap(for mapView: MKMapView)->CLLocation
    {
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: lat, longitude: long)
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RestaurantPage: CLLocationManagerDelegate {
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
extension RestaurantPage: MKMapViewDelegate {
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


