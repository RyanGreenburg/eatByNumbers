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
    var selectedFoodSpot: FoodSpot?
    var selectedVenue: Venue?
    var foodSpotItems: Set<FoodSpot> = []
    var venueItems: Set<Venue> = []
    var currentState = State.open
    var detailsVC = DetailsViewController()
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var drawerView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        mapView.register(VenueAnnotationView.self, forAnnotationViewWithReuseIdentifier: "venuePin")
        mapView.register(FoodSpotAnnotationView.self, forAnnotationViewWithReuseIdentifier: "foodSpotPin")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideDetailsView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServices()
    }
    
    func setViews() {

    }
    
    func updateViews() {
        foodSpotItems = FoodSpotController.shared.nearbyFoodSpots
        venueItems = FoodSpotController.shared.nearbyVenues.filter{ venue in
            return foodSpotItems.contains { $0.hashValue == venue.hashValue } }
        let venues = findVenueAnnotations(venueItems)
        let foodSpots = findFoodSpotAnnotations(foodSpotItems)
        displayAnnotations(foodSpots, venues)
    }
    
    // MARK: - Actions
    
// MARK: - Find Spots(FoodSpot)
    func findFoodSpotAnnotations(_ foodSpots: Set<FoodSpot>) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
        for item in foodSpots {
            // custom annotation?
            let annotation = FoodSpotAnnotation(foodSpot: item)
            annotation.coordinate = item.location.coordinate
            annotation.title = item.name
            annotation.subtitle = item.id
            if !annotations.contains(annotation) {
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
// MARK: - Find Spots (API)
    func findVenueAnnotations(_ venues: Set<Venue>) -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
        for item in venues {
            let annotation = VenueAnnotation(venue: item)
            annotation.coordinate = CLLocationCoordinate2D(latitude: item.location.lat, longitude: item.location.lng)
            annotation.title = item.name
            annotation.subtitle = item.id
            if !annotations.contains(annotation) {
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
    func displayAnnotations(_ foodSpotAnnotations: [MKPointAnnotation], _ venueAnnotations: [MKPointAnnotation]) {
        let annotations = foodSpotAnnotations + venueAnnotations
        mapView.addAnnotations(annotations)
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            if let destinationVC = segue.destination as? DetailsViewController {
                detailsVC = destinationVC
                destinationVC.delegate = self
            }
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
            pinView?.animateDrop()
            return pinView
        }
        
        if let foodSpotAnnotation = annotation as? FoodSpotAnnotation {
            let reuseID = "foodSpotPin"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID, for: foodSpotAnnotation) as? FoodSpotAnnotationView
            pinView?.animateDrop()
            return pinView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? FoodSpotAnnotation {
            view.setSelected(true, animated: true)
            detailsVC.foodSpot = annotation.foodSpot
            showDetailsView()
        } else if let annotation = view.annotation as? VenueAnnotation {
            view.setSelected(true, animated: true)
            detailsVC.venue = annotation.venue
            showDetailsView()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.setSelected(false, animated: true)
        hideDetailsView()
        detailsVC.foodSpot = nil
        detailsVC.venue = nil
    }
}

// MARK: - CoreLocation Delegate
extension FindSpotsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

// MARK: - DrawerView Delegate
extension FindSpotsViewController: DetailsViewControllerDelegate {
    
    func drawerPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panViews(withPoint: CGPoint(x: self.view.center.x, y: self.view.center.y + recognizer.translation(in: drawerView).y))
            recognizer.setTranslation(CGPoint.zero, in: drawerView)
        case .changed:
            panViews(withPoint: CGPoint(x: self.view.center.x, y: self.view.center.y + recognizer.translation(in: drawerView).y))
            recognizer.setTranslation(CGPoint.zero, in: drawerView)
        case .ended:
            recognizer.setTranslation(CGPoint.zero, in: drawerView)
            panDidEnd()
        default:
            break
        }
    }
    
    func panDidEnd() {
        let aboveHalf = self.drawerView.frame.minY > (self.view.frame.height / 3)
        let velocity = detailsVC.panGesture.velocity(in: self.view).y
        
        switch currentState {
        case .closed:
            if velocity < -500 {
                showDetailsView()
            }
            if !aboveHalf {
                showDetailsView()
            }
        case .open:
            if velocity > 500 {
                hideDetailsView()
            }
            if aboveHalf {
                hideDetailsView()
            }
        }
    }
    
    func animateForState(_ state: State, view: UIView, edge: CGFloat, to target: CGFloat, velocity: CGFloat) {
        let distance = target - edge
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            view.frame = view.frame.offsetBy(dx: 0, dy: distance)
        }, completion: nil)
    }
    
    func panViews(withPoint panPoint: CGPoint) {
        if self.drawerView.frame.maxY < self.view.bounds.maxY {
            self.drawerView.center.y += detailsVC.panGesture.translation(in: drawerView).y / 4
        } else {
            self.drawerView.center.y += detailsVC.panGesture.translation(in: drawerView).y
        }
    }
    
    func showDetailsView() {
        let target = view.frame.maxY
        animateForState(currentState, view: drawerView, edge: drawerView.frame.maxY, to: target, velocity: detailsVC.panGesture.velocity(in: drawerView).y)
        currentState = State.open
    }
    
    func hideDetailsView() {
        let target = view.frame.maxY
        animateForState(currentState, view: drawerView, edge: drawerView.frame.minY, to: target, velocity: detailsVC.panGesture.velocity(in: drawerView).y)
        currentState = State.closed
    }
}
