//
//  FindSpotsViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class FindSpotsViewController: UIViewController {

    var locationManager: CLLocationManager {
        return UserController.shared.userLocationManager ?? CLLocationManager()
    }
    var regionInMeters: Double = 1000
    var selectedPlacemark: MKPlacemark?
    var foodSpotItems: [FoodSpot]?
    var venueItems: [Venue]?
    
    
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServices()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func suggestionButtonTapped(_ sender: Any) {
        guard let suggestion = mapView.annotations.randomElement() else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(suggestion)
    }
    
// MARK: - Find Spots(FoodSpot)
    func findFoodSpotAnnotations(_ foodSpots: [FoodSpot]) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
        for item in foodSpots {
            // custom annotation?
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.location.coordinate
            annotation.title = item.name
            annotation.subtitle = item.address
            if !annotations.contains(annotation) {
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
// MARK: - Find Spots (API)
    func findVenueAnnotations(_ venues: [Venue]) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
        for item in venues {
            // custom annotation?
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: item.location.lat, longitude: item.location.lng)
            annotation.title = item.name
            annotation.subtitle = item.location.address
            if !annotations.contains(annotation) {
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
    func displayAnnotations(_ foodSpotAnnotations: [MKPointAnnotation], _ venueAnnotations: [MKPointAnnotation]) {
        var filteredAnnotations = venueAnnotations.filter { (venueAnnotation) -> Bool in
            return foodSpotAnnotations.contains(where: { $0.coordinate.latitude == venueAnnotation.coordinate.latitude && $0.coordinate.longitude == venueAnnotation.coordinate.longitude }) == true ? false : true
        }
        filteredAnnotations += foodSpotAnnotations
        print(filteredAnnotations.count)
        print(foodSpotAnnotations.count)
        print(venueAnnotations.count)
        mapView.addAnnotations(filteredAnnotations)
    }
}

// MARK: - MapView Delegate
extension FindSpotsViewController: UINavigationControllerDelegate, MKMapViewDelegate {
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // show error alert
            let alert = AlertHelper.shared.createAlertControllerWithTitle("Location Services Disabled", andText: "Please enable Location Settings in Settings to use this feature.")
            present(alert, animated: true)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location {
            let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            mapView.removeAnnotations(mapView.annotations)
            guard let spots = foodSpotItems, let items = venueItems else { return }
            let foodSpotAnnotations = findFoodSpotAnnotations(spots)
            let venueAnnotations = findVenueAnnotations(items)
            displayAnnotations(foodSpotAnnotations, venueAnnotations)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.delegate = self
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            break
        case .denied:
            let alert = AlertHelper.shared.createAlertControllerWithTitle("Location Services not Available", andText: "Please enable Location Services in Settings to use this feature.")
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //handle error telling user that they are restricted from using locaiton
            let alert = AlertHelper.shared.createAlertControllerWithTitle("Location Services Restricted", andText: "Location Services have been restriced on your device.")
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPlacemark {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between street address items
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between city and state
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

// MARK: - CoreLocation Delegate
extension FindSpotsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
