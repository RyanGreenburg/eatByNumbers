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
    var foodSpotItems: [FoodSpot] = []
    var venueItems: [Venue] = []
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var hungryButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        suggestionButton.layer.cornerRadius = suggestionButton.frame.width / 2
        centerButton.layer.cornerRadius = centerButton.frame.width / 2
        suggestionButton.imageView?.clipsToBounds = true
        centerButton.imageView?.clipsToBounds = true
        suggestionButton.layer.masksToBounds = true
        centerButton.layer.masksToBounds = true
        centerButton.layer.shadowColor = Colors.darkGray.color().cgColor
        suggestionButton.layer.shadowColor = Colors.darkGray.color().cgColor
        mapView.register(VenueAnnotationView.self, forAnnotationViewWithReuseIdentifier: "venuePin")
        mapView.register(FoodSpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: "foodSpotPin")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServices()
    }
    
    func updateViews() {
        foodSpotItems = FoodSpotController.shared.nearbyFoodSpots
        venueItems = FoodSpotController.shared.nearbyVenues
        let venues = findVenueAnnotations(venueItems)
        let foodSpots = findFoodSpotAnnotations(foodSpotItems)
        displayAnnotations(foodSpots, venues)
    }
    
    // MARK: - Actions
    @IBAction func suggestionButtonTapped(_ sender: Any) {
        guard let suggestion = mapView.annotations.randomElement() else { return }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(suggestion)
    }
    
    @IBAction func userButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() else { return }
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func centerButtonTapped(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    @IBAction func hungryButtonTapped(_ sender: Any) {
        updateViews()
    }
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        let foodSpots = findFoodSpotAnnotations(foodSpotItems)
        let venues = findVenueAnnotations(venueItems)
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.removeAnnotations(mapView.annotations)
            displayAnnotations(foodSpots, venues)
        case 1:
            mapView.removeAnnotations(mapView.annotations)
            displayAnnotations(foodSpots, [])
        case 2:
            mapView.removeAnnotations(mapView.annotations)
            displayAnnotations([], venues)
        default:
            return
        }
    }
    
// MARK: - Find Spots(FoodSpot)
    func findFoodSpotAnnotations(_ foodSpots: [FoodSpot]) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
        for item in foodSpots {
            // custom annotation?
            let annotation = FoodSpotAnnotation(foodSpot: item)
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
            let annotation = VenueAnnotation(venue: item)
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
            
        }
    }
    
    func setAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        let foodSpotAnnotations = findFoodSpotAnnotations(foodSpotItems)
        let venueAnnotations = findVenueAnnotations(venueItems)
        displayAnnotations(foodSpotAnnotations, venueAnnotations)
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
        
        if let venueAnnotation = annotation as? VenueAnnotation {
            let reuseID = "venuePin"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID, for: venueAnnotation) as? VenueAnnotationView
            pinView?.venueDetailDelegate = self
            return pinView
        }
        
        if let foodSpotAnnotation = annotation as? FoodSpotAnnotation {
            let reuseID = "foodSpotPin"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID, for: foodSpotAnnotation) as? FoodSpotAnnotationView
            pinView?.foodSpotDetailDelegate = self
            return pinView
        }
        return nil
    }
    
    func getDirections(){
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

extension FindSpotsViewController: FoodSpotDetailViewDelegate, VenueDetailViewDelegate {
    
    func directionsRequestedFor(_ venue: Venue) {
        let coordinate = CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.lng)
        let placemark = MKPlacemark(coordinate: coordinate)
        selectedPlacemark = placemark
        getDirections()
    }
    
    func directionsRequestedFor(_ foodSpot: FoodSpot) {
        let placemark = MKPlacemark(coordinate: foodSpot.location.coordinate)
        selectedPlacemark = placemark
        getDirections()
    }
}
