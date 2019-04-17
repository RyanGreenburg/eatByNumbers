//
//  FoodSpot.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
import MapKit
import CoreLocation

// conform to NSObject and MKAnnotation to create map items, https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
class FoodSpot {
    
    var name: String
    var address: String
    var location: CLLocation
    var usersFavoriteReferences: [CKRecord.Reference]
    var recordID: CKRecord.ID
    
    init(name: String, address: String, location: CLLocation, usersFavoriteReferences: [CKRecord.Reference] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.address = address
        self.location = location
        self.usersFavoriteReferences = usersFavoriteReferences
        self.recordID = recordID
    }
    
    init?(record: CKRecord) {
        guard let name = record[FoodSpotConstants.nameKey] as? String,
            let address = record[FoodSpotConstants.addressKey] as? String,
            let location = record[FoodSpotConstants.locationKey] as? CLLocation,
            let usersFavoriteReferences = record[FoodSpotConstants.referenceKey] as? [CKRecord.Reference]
            else { return nil }
        
        self.recordID = record.recordID
        self.name = name
        self.address = address
        self.location = location
        self.usersFavoriteReferences = usersFavoriteReferences
    }
}

struct FoodSpotConstants {
    
    static let typeKey = "FoodSpot"
    
    static let nameKey = "name"
    
    static let addressKey = "address"
    
    static let locationKey = "location"
    
    static let referenceKey = "usersFavoriteReferences"
}

extension CKRecord {
    
    convenience init(foodSpot: FoodSpot) {
        self.init(recordType: FoodSpotConstants.typeKey, recordID: foodSpot.recordID)
        
        setValue(foodSpot.name, forKey: FoodSpotConstants.nameKey)
        setValue(foodSpot.address, forKey: FoodSpotConstants.addressKey)
        setValue(foodSpot.location, forKey: FoodSpotConstants.locationKey)
        setValue(foodSpot.usersFavoriteReferences, forKey: FoodSpotConstants.referenceKey)
    }
}

extension FoodSpot: Equatable {
    static func == (lhs: FoodSpot, rhs: FoodSpot) -> Bool {
       return lhs.recordID == rhs.recordID
    }
}
