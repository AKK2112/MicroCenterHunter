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
    let placeName = ""
    let placeInfo = ""
    
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
        
        search.start { [self] myResponse, myError in
            guard let response = myResponse else { return}
            print(response)
            for currentMapItem in response.mapItems {
                self.microCenters.append(currentMapItem)
                //MARK: Stretch 2

                let annotation = MKPointAnnotation()
                annotation.title = currentMapItem.name
                annotation.coordinate = currentMapItem.placemark.coordinate
                if let city = currentMapItem.placemark.locality, let state = currentMapItem.placemark.administrativeArea {
                           annotation.subtitle = "\(parseAddress(currentMapItem: currentMapItem.placemark))"
                       }
//                var placeInfo = parseAddress(currentMapItem: currentMapItem.placemark)
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    func parseAddress(currentMapItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (currentMapItem.subThoroughfare != nil && currentMapItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (currentMapItem.subThoroughfare != nil || currentMapItem.thoroughfare != nil) && (currentMapItem.subAdministrativeArea != nil || currentMapItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (currentMapItem.subAdministrativeArea != nil && currentMapItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            currentMapItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            currentMapItem.thoroughfare ?? "",
            comma,
            // city
            currentMapItem.locality ?? "",
            secondSpace,
            // state
            currentMapItem.administrativeArea ?? ""
            
        )
        print(addressLine)
        var placeInfo = addressLine
        return addressLine
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
           if annotation is MKUserLocation { return nil }

           if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
               annotationView.annotation = annotation
               return annotationView
           } else {
               let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
               annotationView.isEnabled = true
               annotationView.canShowCallout = true

               let btn = UIButton(type: .detailDisclosure)
               annotationView.rightCalloutAccessoryView = btn
               return annotationView
           }
       }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let placename = placeName
//        let placeinfo = "\(parseAddress(currentMapItem: currentMapItem.placemark))"

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

