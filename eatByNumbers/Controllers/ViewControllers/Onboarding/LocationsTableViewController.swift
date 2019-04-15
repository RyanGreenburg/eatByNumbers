//
//  LocationsTableViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/5/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class LocationsTableViewController: UITableViewController {
    
    var venues: [Venue] = []
    
    var mapView: MKMapView?
    var handleMapSearchDelegate: HandleMapSearch?
    let locationManager = CLLocationManager()
    
    
    
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

extension LocationsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        var addressString: String = ""
        let venue = venues[indexPath.row]
        cell.textLabel?.text = venue.name
        
        if let address = venue.location.address {
            addressString += "\(address), "
        }
        
        if let city = venue.location.city {
            addressString += "\(city) "
        }
        
        if let state = venue.location.state {
            addressString += "\(state)"
        }
        
        cell.detailTextLabel?.text = addressString
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = venues[indexPath.row]
        var mapItem: MKMapItem?
        
        if let mapView = mapView {
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = selectedItem.name
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                if let error = error {
                    print("Error completing MKSearch : \(error) \n---\n\(error.localizedDescription)")
                }
                guard let response = response else { return }
                mapItem = response.mapItems.first
                DispatchQueue.main.async {
                    self.handleMapSearchDelegate?.dropPinZoomIn(mapItem!.placemark)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            guard let address = selectedItem.location.address,
                let name = selectedItem.name
                else { return }
            let location = CLLocation(latitude: selectedItem.location.lat, longitude: selectedItem.location.lng)
            let newFoodSpot = FoodSpot(name: name, address: address, location: location)
            if UserController.shared.userFoodSpots.count < 10 {
                UserController.shared.userFoodSpots.append(newFoodSpot)
                FoodSpotController.shared.saveFoodSpot(withName: name, address: address, location: location) { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                let alert = AlertHelper.shared.createAlertControllerWithTitle("Favorite Spots are Full!", andText: "You've filled up all 10 of your favorite spots. Hit done to continue, or you can edit your favorite spots.")
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension LocationsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let location = locationManager.location?.coordinate,
            let searchTerm = searchController.searchBar.text else { return }
        
        let locationString = "\(location.latitude),\(location.longitude)"
        
        if searchTerm.count >= 3 {
            FoodSeachController.shared.suggestedCompletionSearchWith(searchTerm: searchTerm, location: locationString) { (foundVenues) in
                
                let filtered = foundVenues.filter{ $0.categories.contains{ $0.name == "Food" }}
                
                self.venues = filtered
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
