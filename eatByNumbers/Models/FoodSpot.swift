//
//  FoodSpot.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation

class FoodSpot: CloudKitSyncable {
    
    let id: String
    var name: String?
    var address: String
    var location: CLLocation
    var listReferences: [CKRecord.Reference]
    var recordID: CKRecord.ID
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: FoodSpot.recordType, recordID: self.recordID)
        record.setValue(self.id, forKey: FoodSpotConstants.idKey)
        record.setValue(self.name, forKey: FoodSpotConstants.nameKey)
        record.setValue(self.address, forKey: FoodSpotConstants.addressKey)
        record.setValue(self.location, forKey: FoodSpotConstants.locationKey)
        record.setValue(self.listReferences, forKey: FoodSpotConstants.referenceKey)
        return record
    }
    static var recordType: CKRecord.RecordType {
        return FoodSpotConstants.typeKey
    }
    
    init(id: String, name: String, address: String, location: CLLocation, listReferences: [CKRecord.Reference] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.listReferences = listReferences
        self.recordID = recordID
    }
    
    required init?(record: CKRecord) {
        guard let id = record[FoodSpotConstants.idKey] as? String,
            let name = record[FoodSpotConstants.nameKey] as? String,
            let address = record[FoodSpotConstants.addressKey] as? String,
            let location = record[FoodSpotConstants.locationKey] as? CLLocation,
            let listReferences = record[FoodSpotConstants.referenceKey] as? [CKRecord.Reference]
            else { return nil }
        
        self.recordID = record.recordID
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.listReferences = listReferences
    }
}

extension FoodSpot: Hashable {
    static func == (lhs: FoodSpot, rhs: FoodSpot) -> Bool {
        return lhs.recordID == rhs.recordID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

struct FoodSpotConstants {
    
    static let typeKey = "FoodSpot"
    static let idKey = "id"
    static let nameKey = "name"
    static let addressKey = "address"
    static let locationKey = "location"
    static let referenceKey = "listReferences"
}
