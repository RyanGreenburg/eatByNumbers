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
    
    var isFoodSpot: Bool
    
    init(isFoodSpot: Bool) {
        self.isFoodSpot = isFoodSpot
    }
}


class VenueSpotAnnotation: MKPointAnnotation {
    
    var isVenue: Bool
    
    init(isVenue: Bool) {
        self.isVenue = isVenue
    }
}
