//
//  ViewController.swift
//  MicroCenterHunter
//
//  Created by Alec Kinzie on 3/16/22.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
//    var currentLocation: CLLocation!
    var microCenters: [MKMapItem] = []
    var currentLocation = CLLocation(latitude: 41.8781, longitude: -87.6298)
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userLocation.title = "My Location"
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        
    }
    
    @IBAction func zoomIn(_ sender: UIBarButtonItem) {
        let center = CLLocation(latitude: 41.8781, longitude: -87.6298)
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let myRegion = MKCoordinateRegion(center: center.coordinate, span: span)
        mapView.setRegion(myRegion, animated: true)
    }
    
    //MARK: Stretch 1
    @IBAction func findMicroCenter(_ sender: UIBarButtonItem) {
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = "MicroCenter"
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        
        search.start { myResponse, myError in
            guard let response = myResponse else { return}
            print(response)
            for currentMapItem in response.mapItems {
                self.microCenters.append(currentMapItem)
                //MARK: Stretch 2

                let annotation = MKPointAnnotation()
                annotation.title = currentMapItem.name
                annotation.coordinate = currentMapItem.placemark.coordinate
                if let city = currentMapItem.placemark.locality, let state = currentMapItem.placemark.administrativeArea {
                           annotation.subtitle = "\(city) \(state)"
                       }
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    
    
}

