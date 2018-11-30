//
//  ViewController.swift
//  FinalProject
//
//  Created by Rahul Tasker on 11/26/18.
//  Copyright © 2018 Tasker. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import MapKit
import Contacts

class ViewController: UIViewController {
    
    //MARK:- IBOutlets and variables
    @IBOutlet weak var addOneInput: UILabel!
    @IBOutlet weak var addTwoInput: UILabel!
    @IBOutlet weak var findLocationButton: UIButton!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentPage = 0
    var spot1: Spot!
    var spot2: Spot!
    var isAdd1 = false
    var midLon = 0.0
    var midLat = 0.0

    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addOneInput.text = ""
        addTwoInput.text = ""
        findLocationButton.isEnabled = false
        if spot1 == nil { // We are adding a new record, fields should be editable
            spot1 = Spot()
        }
        if spot2 == nil { // We are adding a new record, fields should be editable
            spot2 = Spot()
        }

    }
    
    //MARK:- Prepare segue to Map
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToMap" {
            self.midLon = (spot1.coordinate.longitude + spot2.coordinate.longitude) / 2
            self.midLat = (spot1.coordinate.latitude + spot2.coordinate.latitude) / 2
            let destination = segue.destination as! MapViewController
            destination.midLon = self.midLon
            destination.midLat = self.midLat
        }
    }
    
    //MARK:- IBActions
    @IBAction func findAddOneButtonPressed(_ sender: UIButton) {
        isAdd1 = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        checkToEnableButton()
    }
    
    
    @IBAction func findAddTwoButtonPressed(_ sender: UIButton) {
        isAdd1 = false
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        checkToEnableButton()
    }
    
    
    //TODO:- fix by setting 2 spot variables and getting coordinates from them
    @IBAction func searchButtonPressed(_ sender: Any) {
        print("*************** reached1 \(spot1.coordinate.longitude), \(spot1.coordinate.latitude)")
        print("*************** reached2 \(spot2.coordinate.longitude), \(spot2.coordinate.latitude)")
        print("*************** reachedMid \(self.midLon), \(self.midLat)")
    }
    
    func checkToEnableButton() {
        if (addOneInput.text == "" || addTwoInput.text == "") {
            if findLocationButton.isEnabled == true {
                findLocationButton.isEnabled = false
            }
        }
        if (addTwoInput.text != "" && addTwoInput.text != "") {
            if findLocationButton.isEnabled == false {
                findLocationButton.isEnabled = true
            }
        }
    }
    
    func getCurrentLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func updateUserInterface() {
        if isAdd1 == true {
            addOneInput.text = spot1.address
        } else {
            addTwoInput.text = spot2.address
        }
        checkToEnableButton()
    }

}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if isAdd1 == true {
            spot1.name = place.name
            spot1.address = place.formattedAddress ?? ""
            spot1.coordinate = place.coordinate
        }
        else {
            spot2.name = place.name
            spot2.address = place.formattedAddress ?? ""
            spot2.coordinate = place.coordinate
        }
        dismiss(animated: true, completion: nil)
        updateUserInterface()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController : CLLocationManagerDelegate {
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting the UIApplicationOpenSettingsURLString")
            return
        }
        let settingsActions = UIAlertAction(title: "Settings", style: .default) { value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsActions)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isAdd1 {
            guard spot1.name == "" else {
                return
            }
            let geoCoder = CLGeocoder()
            var name = ""
            var address = ""
            currentLocation = locations.last
            spot1.coordinate = currentLocation.coordinate
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
                if placemarks != nil {
                    let placemark = placemarks?.last
                    name = placemark?.name ?? "name unknown"
                    // need to import Contacts to use this code:
                    if let postalAddress = placemark?.postalAddress {
                        address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                    }
                } else {
                    print("*** Error retrieving place. Error code: \(error!.localizedDescription)")
                }
                self.spot1.name = name
                self.spot1.address = address
                self.updateUserInterface()
            })
        } else {
            guard spot2.name == "" else {
                return
            }
            let geoCoder = CLGeocoder()
            var name = ""
            var address = ""
            currentLocation = locations.last
            spot2.coordinate = currentLocation.coordinate
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {placemarks, error in
                if placemarks != nil {
                    let placemark = placemarks?.last
                    name = placemark?.name ?? "name unknown"
                    // need to import Contacts to use this code:
                    if let postalAddress = placemark?.postalAddress {
                        address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                    }
                } else {
                    print("*** Error retrieving place. Error code: \(error!.localizedDescription)")
                }
                self.spot2.name = name
                self.spot2.address = address
                self.updateUserInterface()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location.")
    }
}



