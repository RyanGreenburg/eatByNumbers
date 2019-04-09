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

    let locationManager = CLLocationManager()
    var regionInMeters: Double = 1000
    var selectedPlacemark: MKPlacemark?
    @IBOutlet weak var suggestionButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        closeButton.layer.cornerRadius = closeButton.frame.height / 2
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
    func findFoodSpotsNear(location: CLLocation) -> [MKMapItem] {
        // filter spots by location
        var mapItems: [MKMapItem] = []
        
        for spot in FoodSpotController.shared.allFoodSpots {
            if spot.location.distance(from: location) <= regionInMeters {
                // perform map request for all nearby spots
                let item = performMapSearchRequestWith(query: spot.name)
                mapItems.append(item)
            }
        }
        return mapItems
    }
    
    func performMapSearchRequestWith(query: String) -> MKMapItem {
        var mapItem = MKMapItem()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("Error completing MKSearch : \(error) \n---\n\(error.localizedDescription)")
            }
            guard let foundMapItem = response?.mapItems.first else { return }
            mapItem = foundMapItem
        }
        return mapItem
    }
    
    func displayFoodSpot(mapItems: [MKMapItem]) {
        for item in mapItems {
            // custom annotation?
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            annotation.subtitle = parseAddress(selectedItem: item.placemark)
            mapView.addAnnotation(annotation)
        }
    }
    
// MARK: - Find Spots (API)
    func findVenuesNear(location: CLLocation) -> [MKMapItem] {
        var mapItems: [MKMapItem] = []
        guard let location = locationManager.location else { return [] }
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        FoodSeachController.shared.searchWith(searchTerm: nil, location: locationString) { (foundVenues) in
            
            let filtered = foundVenues.filter{ $0.categories.contains{ $0.name == "Food" }}
            
            for item in filtered {
                guard let name = item.name else { return }
                let item = self.performMapSearchRequestWith(query: name)
                mapItems.append(item)
            }
        }
        return mapItems
    }
    
    func displayVenue(mapItems: [MKMapItem]) {
        for item in mapItems {
            // custom annotation?
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            annotation.subtitle = parseAddress(selectedItem: item.placemark)
            mapView.addAnnotation(annotation)
        }
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
            let spots = findFoodSpotsNear(location: location)
            let venues = findVenuesNear(location: location)
            mapView.removeAnnotations(mapView.annotations)
            displayFoodSpot(mapItems: spots)
            displayVenue(mapItems: venues)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
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
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = Colors.lightBlue.color()
        pinView?.canShowCallout = true
        let smallSqure = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSqure))
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
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
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters , longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}