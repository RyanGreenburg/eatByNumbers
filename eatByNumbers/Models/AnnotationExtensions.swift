//
//  AnnotationExtensions.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import MapKit

class FoodSpotAnnotation: NSObject, MKAnnotation {
    
    var foodSpot: FoodSpot
    var coordinate: CLLocationCoordinate2D {
        return foodSpot.location.coordinate
    }
    
    init(foodSpot: FoodSpot) {
        self.foodSpot = foodSpot
    }
    
    var title: String? {
        return foodSpot.name
    }
    
    var subtitle: String? {
        return foodSpot.address
    }
}


class VenueSpotAnnotation: NSObject, MKAnnotation {
    
    var venue: Venue
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.lng)
    }
    
    init(venue: Venue) {
        self.venue = venue
    }
    
    var title: String? {
        return venue.name
    }
    
    var subtitle: String? {
        return venue.location.address
    }
}
