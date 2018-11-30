//
//  MapViewController.swift
//  FinalProject
//
//  Created by Rahul Tasker on 11/26/18.
//  Copyright © 2018 Tasker. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //TODO:- get points of interest and plot them instead of using exact midpoint
    
    //MARK:- IBOutlets and variables
    @IBOutlet weak var mapView: MKMapView!
    let regionDistance: CLLocationDistance = 750
    let key = "AIzaSyAVuJIbJ0vYu9USI4xzRNTl-BWaviYbAKc"
    
    var midLon: Double!
    var midLat: Double!
    var spot: Spot!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        if midLon == 0.0 || midLat == 0.0 {
            //center to current location - show alert
            showAlert(title: "Could not fine Halfway Point", message: "Invalid coordinates to display Halfway Point")
        }
        else {
            centerAroundCoordinates()
        }
    }
    
    //MARK:- Functions
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func centerAroundCoordinates() {
        //Center around coordinates
        let coordinate = CLLocationCoordinate2D(latitude: self.midLat, longitude: self.midLon)
        print("****** Coordinates: \(String(describing: midLat)), \(String(describing: midLon))")
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: midLat, longitude: midLon)
        var address = ""
        var streetName = ""
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                // Place details
                guard let placeMark = placemarks!.first else {
                    self.showAlert(title: "Error", message: "Something went wrong when finding address")
                    return
                    
                }
                
                // Location name
                if let locationName = placeMark.location {
                    print(locationName)
                }
                // Street address
                if let street = placeMark.thoroughfare {
                    streetName = street
                }
                // City
                if let city = placeMark.subAdministrativeArea {
                    // Zip code
                    if let zip = placeMark.isoCountryCode {
                        // Country
                        if let country = placeMark.country {
                            address = "\(city), \(zip), \(country)"
                        }
                    }
                }
                self.spot = Spot(name: streetName, address: address, coordinate: coordinate)
                self.updateMap()
        })
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }

}

