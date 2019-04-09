//
//  FoodSpotController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class FoodSpotController {
    
    // singleton
    static let shared = FoodSpotController()
    // source of truth
    var allFoodSpots: [FoodSpot] = []
    
    // MARK: - CRUD
    
    // save
    func saveFoodSpot(withName name: String, address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetcing user Apple ID : \(error.localizedDescription)")
                completion(false)
            }
            
            guard let recordID = recordID else { completion(false) ; return }
            
            let reference = [CKRecord.Reference(recordID: recordID, action: .deleteSelf)]
            let newFoodSpot = FoodSpot(name: name, address: address, location: location, usersFavoriteReferences: reference)
            
            let foodSpotRecord = CKRecord(foodSpot: newFoodSpot)
            
            CloudKitManager.shared.save(record: foodSpotRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving Food Spot to CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                
                guard let record = record,
                    let foodSpot = FoodSpot(record: record) else { completion(false) ; return }
                
                self.allFoodSpots.append(foodSpot)
                completion(true)
            })
        }
    }
    
    // read
    func fetchSpots(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        CloudKitManager.shared.performFetch(recordType: FoodSpotConstants.typeKey, predicate: predicate) { (records, error) in
            if let error = error {
                print("Error fetching Food Spots from CloudKit : \(error.localizedDescription)")
                completion(false)
            }
            guard let records = records else { return }
            let foundSpots = records.compactMap( {FoodSpot(record: $0)} )
            self.allFoodSpots = foundSpots
            completion(true)
        }
    }
    
    // update
    func update(foodSpot: FoodSpot, withName name: String, address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        //remove food spot from array?
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetcing user Apple ID : \(error.localizedDescription)")
                completion(false)
            }
            
            guard let recordID = recordID else { completion(false) ; return }
            
            let reference = [CKRecord.Reference(recordID: recordID, action: .deleteSelf)]
            let newFoodSpot = FoodSpot(name: name, address: address, location: location, usersFavoriteReferences: reference)
            
            let foodSpotRecord = CKRecord(foodSpot: newFoodSpot)
            
            CloudKitManager.shared.save(record: foodSpotRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving Food Spot to CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                
                guard let record = record,
                    let foodSpot = FoodSpot(record: record) else { completion(false) ; return }
                
                self.allFoodSpots.append(foodSpot)
                completion(true)
            })
        }
    }
    
    // delete
    func delete(foodSpot: FoodSpot, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            
            guard let recordID = recordID else { completion(false) ; return }
            
            CloudKitManager.shared.delete(record: recordID, completion: { (error) in
                if let error = error {
                    print("Error deleting user from CloudKit : \(error.localizedDescription)")
                }
                // remove food spot?
                
                completion(true)
            })
        }
    }
}
