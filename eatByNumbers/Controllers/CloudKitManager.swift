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

    // Generics
    /**
     Saves a CKRecord to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: The object saved to CloudKit
        - Result Failure: The Error that was thrown
     */
    public func save<T: CloudKitSyncable>(object: T, completion: @escaping (Result<T, Error>) -> Void) {
        
        let record = object.ckRecord
        publicDB.save(record) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            print("Saved record to CloudKit")
            completion(.success(object))
        }
    }
    
    /**
     Updates a CKRecord that is saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: The object saved to CloudKit
        - Result Failure: The Error that was thrown
     */
    public func update<T: CloudKitSyncable>(_ object: T, completion: @escaping (Result<T, Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: [object.ckRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
            }
            print("Updated record in CloudKit")
            completion(.success(object))
        }
        publicDB.add(operation)
    }
    
    /**
     Fetches an array of CKRecords that are saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - predicate: The CompoundPredicate of search parameters
        - completion: Completes with a Result
     
     - Returns:
        - .success: Result yields an array of objects saved to CloudKit
        - .failure: The Error that was thrown
     */
    public func performFetch<T: CloudKitSyncable>(predicate: NSCompoundPredicate, completion: @escaping (Result<[T]?, Error>) -> Void) {
        
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            guard let records = records else { completion(.failure(error!)) ; return }
            let objects: [T] = records.compactMap { T(record: $0) }
            print("Fetched objects from CloudKit")
            completion(.success(objects))
        }
    }
    
    /**
     Fetches the users appleUserReference
     
     - Returns:
        - CKRecord.Reference: The logged in user's appleUserReference
     */
    public func fetchAppleUserReference() -> CKRecord.Reference? {
        var referenceToReturn: CKRecord.Reference?
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                referenceToReturn = reference
            }
        }
        return referenceToReturn
    }
    
    /**
     Deletes a CKRecord that is saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: Boolean indicating success
        - Result Failure: The Error that was thrown
     */
    public func delete<T: CloudKitSyncable>(_ object: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [object.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
            }
            print("Deleted object from CloudKit")
            completion(.success(true))
        }
        publicDB.add(operation)
    }
}


public protocol CloudKitSyncable {
    
    var recordID: CKRecord.ID { get set }
    var ckRecord: CKRecord { get }
    static var recordType: CKRecord.RecordType { get }
    init?(record: CKRecord)
}
