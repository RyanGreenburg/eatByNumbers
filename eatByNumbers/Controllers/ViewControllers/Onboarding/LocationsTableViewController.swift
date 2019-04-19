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
        
        cell.textLabel?.textColor = Colors.white.color()
        cell.textLabel?.backgroundColor = .clear
        cell.detailTextLabel?.textColor = Colors.white.color()
        cell.detailTextLabel?.backgroundColor = .clear
        cell.backgroundColor = Colors.darkBlue.color().withAlphaComponent(0.8)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = venues[indexPath.row]
        
        if mapView != nil {
            
            let coordinate = CLLocationCoordinate2D(latitude: selectedItem.location.lat, longitude: selectedItem.location.lng)
            
            let placemark = MKPlacemark(coordinate: coordinate)
            DispatchQueue.main.async {
                self.handleMapSearchDelegate?.dropPinZoomIn(placemark, selectedItem)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            guard let address = selectedItem.location.address,
                let name = selectedItem.name
                else { return }
            let location = CLLocation(latitude: selectedItem.location.lat, longitude: selectedItem.location.lng)
            let newFoodSpot = FoodSpot(name: name, address: address, location: location)
            let filtered = UserController.shared.userFoodSpots.filter { $0.recordID == newFoodSpot.recordID }
            
            if UserController.shared.userFoodSpots.count < 10 && filtered.count == 0 {
                FoodSpotController.shared.saveFoodSpot(withName: name, address: address, location: location) { (success) in
                    if success {
                        NotificationCenter.default.post(name: Notification.Name("userFoodSpotsChanged"), object: nil)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                let alert = AlertHelper.shared.createAlertControllerWithTitle("Oh No!", andText: "You've filled up all 10 of your favorite spots or this spot is already on your list.")
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
