//
//  CloudKitManager.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func save(record: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void) {
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error saving record to public database : \(error.localizedDescription)")
                completion(nil, error)
            }
            
            guard let record = record else { completion(nil, nil) ; return }
            completion(record, nil)
        }
    }
    
    func update(record: CKRecord, completion: @escaping (Error?) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error updating record in public database : \(error.localizedDescription)")
                completion(error)
            }
            completion(nil)
        }
        publicDB.add(operation)
    }
    
    func performFetch(recordType: String, predicate: NSPredicate, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                // Further error handling
                print("Error performing fetch : \(error.localizedDescription)")
                completion(nil, error)
            }
            guard let records = records else { completion(nil, nil) ; return }
            completion(records, nil)
        }
    }
    
    func delete(record: CKRecord.ID, completion: @escaping (Error?) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error deleting record from CloudKit : \(error.localizedDescription)")
                completion(error)
            }
            completion(nil)
        }
        publicDB.add(operation)
    }
}
