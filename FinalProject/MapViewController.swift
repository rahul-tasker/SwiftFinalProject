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
    
    //MARK:- IBOutlets and variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    let regionDistance: CLLocationDistance = 1200
    
    var searchActive : Bool = false
    var midLon: Double!
    var midLat: Double!
    var spot: Spot!
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
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
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                // Place details
                guard let placeMark = placemarks!.first else {
                    self.showAlert(title: "Error", message: "Something went wrong when finding address")
                    return
                }
                
                // Street address
                if let street = placeMark.thoroughfare {
                    if let city = placeMark.subAdministrativeArea {
                        // Zip code
                        if let zip = placeMark.isoCountryCode {
                            // Country
                            if let country = placeMark.country {
                                address = "\(street), \(city), \(zip), \(country)"
                            }
                        }
                    }
                }
                self.spot = Spot(name: "Halfway Point", address: address, coordinate: coordinate)
                self.updateMap()
                
        })
    }
    
    func makeRequest(text: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return
            }
            for item in response.mapItems {
                var name = ""
                var address = ""
                // Location name
                if let locationName = item.placemark.name {
                    name = "\(locationName)"
                }
                // Street address
                if let number = item.placemark.subThoroughfare {
                    if let street = item.placemark.thoroughfare {
                        // City
                        if let city = item.placemark.subAdministrativeArea {
                            // Zip code
                            if let zip = item.placemark.isoCountryCode {
                                address = "\(number) \(street), \(city), \(zip)"
                                
                            }
                        }
                    }
                }
                
                let coordinate = item.placemark.coordinate
                let spotTemp = Spot(name: name , address: address, coordinate: coordinate)
                self.mapView.addAnnotation(spotTemp)
                
            }
        }
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }

}

extension MapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        makeRequest(text: searchText)
        self.updateMap()
    }
}
