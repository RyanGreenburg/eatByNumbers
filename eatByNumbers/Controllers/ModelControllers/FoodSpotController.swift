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
    var allFoodSpots: [FoodSpot] = [] {
        didSet {
            guard let userLocation = UserController.shared.userLocationManager?.location
                else { return }
            nearbyFoodSpots = allFoodSpots.filter({ $0.location.distance(from: userLocation) <= 80467 })
        }
    }
    
    // spots within 50 miles of the user
    var nearbyFoodSpots: [FoodSpot] = []
    
    // API Call
    var nearbyVenues: [Venue] = []
    
    // MARK: - CRUD
    
    // save
    func saveFoodSpot(withName name: String, id: String, address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(format: "name == %@", name)
        let query = CKQuery(recordType: FoodSpotConstants.typeKey, predicate: predicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching record for foodSpot : \(error.localizedDescription)")
                completion(false)
            }
            guard let records = records else { completion(false) ; return }
            
            if records.isEmpty {
                guard let recordID = UserController.shared.loggedInUser?.recordID else { completion(false) ; return }
                
                let reference = [CKRecord.Reference(recordID: recordID, action: .deleteSelf)]
                let newFoodSpot = FoodSpot(id: id, name: name, address: address, location: location, usersFavoriteReferences: reference)
                
                let foodSpotRecord = CKRecord(foodSpot: newFoodSpot)
                
                CloudKitManager.shared.save(record: foodSpotRecord, completion: { (record, error) in
                    if let error = error {
                        print("Error saving Food Spot to CloudKit : \(error.localizedDescription)")
                        completion(false)
                    }
                    
                    guard let record = record,
                        let foodSpot = FoodSpot(record: record) else { completion(false) ; return }
                    self.allFoodSpots.append(foodSpot)
                    UserController.shared.userFoodSpots.append(foodSpot)

                    completion(true)
                })
            } else {
                let foodSpot = FoodSpot(record: records.first!)
                guard let user = UserController.shared.loggedInUser else { completion(false) ; return }
                let userRef = CKRecord.Reference(recordID: user.recordID, action: .none)
                if foodSpot!.usersFavoriteReferences.contains(userRef) {
                    // do nothing
                } else {
                    foodSpot?.usersFavoriteReferences.append(userRef)
                    
                    CloudKitManager.shared.save(record: CKRecord(foodSpot: foodSpot!), completion: { (record, error) in
                        if let error = error {
                            print("Error saving record to foodSpot : \(error.localizedDescription)")
                            completion(false)
                        }
                        guard record != nil else { completion(false) ; return }
                        completion(true)
                    })
                }
            }
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
            guard let records = records else { completion(false) ; return }
            let foundSpots = records.compactMap( {FoodSpot(record: $0)} )
            print("Fetched all foodSpots")
            self.allFoodSpots = foundSpots
            guard let userRecordID = UserController.shared.loggedInUser?.recordID else { return }
            let userFoodSpots = self.allFoodSpots.filter{( $0.usersFavoriteReferences.contains{( $0.recordID == userRecordID)} )}
            
            UserController.shared.userFoodSpots = userFoodSpots
            completion(true)
        }
    }
    
    // update
    func remove(user: User, fromFoodSpot foodSpot: FoodSpot, completion: @escaping (Bool) -> Void) {
        let foodSpotRefs = foodSpot.usersFavoriteReferences
        let filteredRefs = foodSpotRefs.filter { $0.recordID != user.recordID }
        foodSpot.usersFavoriteReferences = filteredRefs
        
        if filteredRefs.count == 0 {
            delete(foodSpot: foodSpot) { (success) in
                if success {
                    completion(true)
                }
                completion(false)
            }
        } else {

            let updateRecord = CKRecord(foodSpot: foodSpot)
            
            CloudKitManager.shared.update(record: updateRecord) { (error) in
                if let error = error {
                    print("Error updating record : \(error.localizedDescription)")
                    completion(false)
                }
                completion(true)
            }
        }
    }
    
    // delete
    func delete(foodSpot: FoodSpot, completion: @escaping (Bool) -> Void) {
        
        CloudKitManager.shared.delete(record: foodSpot.recordID) { (error) in
            if let error = error {
                print("Error deleting foodSpot record : \(error.localizedDescription)")
                completion(false)
            }
            completion(true)
        }
    }
}
