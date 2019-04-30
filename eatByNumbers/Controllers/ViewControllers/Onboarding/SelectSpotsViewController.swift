//
//  SelectSpotsViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class SelectSpotsViewController: UIViewController {
    
    var user: User?
    var foodSpots: [FoodSpot] = []
    
    var resultsController: UISearchController?
    var selectedVenue: Venue?
    var locationManager: CLLocationManager {
        return UserController.shared.userLocationManager ?? CLLocationManager()
    }
    
    var regionInMeters: Double = 1000
    
    @IBOutlet weak var selectSpotsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = false
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setSearchController()
        checkLocationServices()
        setViews()
    }

    func setSearchController() {
        let storyboard = UIStoryboard(name: "SelectFavSpots", bundle: nil)
        let locationsTVC = storyboard.instantiateViewController(withIdentifier: "locationsTableViewController") as? LocationsTableViewController
        resultsController = UISearchController(searchResultsController: locationsTVC)
        resultsController?.searchResultsUpdater = locationsTVC
        let searchBar = resultsController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for food spots"
        navigationItem.titleView = resultsController?.searchBar
        resultsController?.hidesNavigationBarDuringPresentation = false
        resultsController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationsTVC?.tableView.tableFooterView = UIView()
        locationsTVC?.tableView.tableFooterView?.backgroundColor = .clear
        locationsTVC?.mapView = self.mapView
        locationsTVC?.handleMapSearchDelegate = self
    }
    
    @objc func addFavorite() {
        guard let venue = selectedVenue,
            let name = venue.name,
            let address = venue.location.address
            else { return }
        
        let id = venue.id
        
        let location = CLLocation(latitude: venue.location.lat, longitude: venue.location.lng)
        
        let newFoodSpot = FoodSpot(id: id, name: name, address: address, location: location)
        
        if foodSpots.count < 10 {
            foodSpots.append(newFoodSpot)
        } else {
            let alert = AlertHelper.shared.createAlertControllerWithTitle("Favorite Spots are Full!", andText: "You've filled up all 10 of your favorite spots. Hit done to continue, or you can edit your favorite spots.")
            present(alert, animated: true, completion: nil)
        }
        
        FoodSpotController.shared.saveFoodSpot(withName: name, id: id, address: address, location: location) { (success) in
            if success {
                DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.centerViewOnUserLocation()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func doneBarButtonTapped(_ sender: Any) {
        
        goToHomePage()
    }
    
    func goToHomePage() {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() else { return }
        
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - Map Delegate
extension SelectSpotsViewController: MKMapViewDelegate, UINavigationControllerDelegate {
    
    // MARK: - Class methods
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            let alert = AlertHelper.shared.blankAlertController("No Location Found", andText: "Eat10 was unable to find your current location. They key features of this app rely on the user's location. Please check settings to see if Location Services are enabled.")
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
        button.setBackgroundImage(UIImage(named: "logo"), for: .normal)
        button.addTarget(self, action: #selector(addFavorite), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
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

extension SelectSpotsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension SelectSpotsViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark, _ venue: Venue) {
        selectedVenue = venue
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = venue.name
        annotation.subtitle = venue.location.address
    
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark: MKPlacemark, _ venue: Venue)
}

// MARK: - TableView DataSource/Delegate
extension SelectSpotsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        let location = foodSpots[indexPath.row]
        
        cell.textLabel?.text = location.name
        cell.textLabel?.textColor = Colors.white.color()
        cell.detailTextLabel?.text = location.address
        cell.detailTextLabel?.textColor = Colors.white.color()
        
        cell.backgroundColor = .clear
        
        return cell
    }
}

extension SelectSpotsViewController {
    func setViews() {
        tableView.backgroundColor = .clear
        self.view.backgroundColor = Colors.lightGray.color()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = .clear
        selectSpotsLabel.textColor = Colors.darkBlue.color()
    }
}
