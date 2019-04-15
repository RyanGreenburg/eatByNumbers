//
//  AnnotationExtensions.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class FoodSpotAnnotation: MKPointAnnotation {
    
    var foodSpot: FoodSpot
    var location: CLLocationCoordinate2D {
        return foodSpot.location.coordinate
    }
    
    init(foodSpot: FoodSpot) {
        self.foodSpot = foodSpot
    }
    
    var name: String {
        return foodSpot.name
    }
    
    var address: String {
        return foodSpot.address
    }
}


class VenueAnnotation: MKPointAnnotation {
    
    var venue: Venue
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.lng)
    }
    
    init(venue: Venue) {
        self.venue = venue
    }
    
    var name: String {
        return venue.name ?? ""
    }
    var address: String {
        return venue.location.address ?? ""
    }
}
