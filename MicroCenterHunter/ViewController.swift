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
    var phoneNumber: [String] = []
    var currentLocation = CLLocation(latitude: 41.8781, longitude: -87.6298)
    var placeName = ""
    var placeInfo = ""
    
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
        let center = currentLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 10)
        let myRegion = MKCoordinateRegion(center: center, span: span)
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
                self.phoneNumber.append(currentMapItem.phoneNumber ?? "Not Provided")
                print(currentMapItem.phoneNumber)
                print(phoneNumber)
                let annotation = MKPointAnnotation()
                annotation.title = currentMapItem.name
                annotation.coordinate = currentMapItem.placemark.coordinate
                annotation.subtitle = "\(parseAddress(currentMapItem: currentMapItem.placemark))"
                placeName = parseAddress(currentMapItem: currentMapItem.placemark)
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
         placeName = addressLine
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
    
//
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let ac = UIAlertController(title: placeName, message: phoneNumber.joined(), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}


