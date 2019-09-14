//
//  Location.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 9/12/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class List: CloudKitSyncable {
    
    var name: String
    var spotCount: Int
    
    var recordID: CKRecord.ID
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: List.recordType, recordID: self.recordID)
        record.setValuesForKeys([
            ListStrings.nameKey : self.name,
            ListStrings.spotCountKey : self.spotCount,
            ListStrings.userReferenceKey : self.userReference
            ])
        
        return record
    }
    var userReference: CKRecord.Reference
    static var recordType: CKRecord.RecordType {
        return ListStrings.typeKey
    }
    
    init(name: String, spotCount: Int = 0, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference) {
        self.name = name
        self.spotCount = spotCount
        self.recordID = recordID
        self.userReference = userReference
    }
    
    required init?(record: CKRecord) {
        guard let name = record[ListStrings.nameKey] as? String,
            let spotCount = record[ListStrings.spotCountKey] as? Int,
            let userReference = record[ListStrings.userReferenceKey] as? CKRecord.Reference
            else { return nil }
        
        self.name = name
        self.spotCount = spotCount
        self.userReference = userReference
        self.recordID = record.recordID
    }
}

struct ListStrings {
    static let typeKey = "List"
    static let nameKey = "name"
    static let spotCountKey = "spotCount"
    static let userReferenceKey = "userReference"
}
