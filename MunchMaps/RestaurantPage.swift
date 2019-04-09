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

class RestaurantPage: UIViewController {

    let locationManager = CLLocationManager()
    var futureRest = [Search.Restaurant]()
    @IBOutlet weak var Add: UIButton!
    let regionmeters: Double = 10000
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var restaurant_Name: UILabel!
    var previousLocation: CLLocation?
    var rest_info = Search.Restaurant(name: "", address: "", Latlocation: CLLocationCoordinate2D(latitude: 0, longitude: 0), saved: false)
    
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
        if (rest_info.saved == false)
        {
            Add.setTitle("add", for: .normal)
            Add.setTitleColor(.blue, for: .normal)
        }
        else
        {
            print("saved")
            Add.setTitle("saved", for: .normal)
            Add.setTitleColor(.green, for: .normal)
        }
    }
    @IBAction func Add_button(_ sender: Any) {
        if (rest_info.saved == false)
        {
            Search.GlobalVariables.savedRest.append(rest_info)
            Add.setTitleColor(.green, for: .normal)
            Add.setTitle("Saved", for: .normal)
            let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
            Search.GlobalVariables.restaurantResults[ind!].saved = true
            for i in Search.GlobalVariables.savedRest
            {
                print(i.name)
            }
        }
        else
        {
            Search.GlobalVariables.savedRest = Search.GlobalVariables.savedRest.filter{ $0.name != rest_info.name}
            Add.setTitleColor(.blue, for: .normal)
            Add.setTitle("Add", for: .normal)
            let ind = Search.GlobalVariables.restaurantResults.firstIndex(where: {$0.address == rest_info.address})
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
