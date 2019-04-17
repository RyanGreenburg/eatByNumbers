//
//  UserController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class UserController {
    
    // Singleton
    static let shared = UserController()
    
    // Source of truth
    var loggedInUser: User?
    
    // User's spots
    var userFoodSpots: [FoodSpot] = []
    
    // User's location
    var userLocationManager: CLLocationManager?
    
    // MARK: - CRUD
    
    // create
    func createUserWith(name: String, photo: UIImage, foodSpotsRefs: [CKRecord.Reference]?, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            guard let recordID = recordID
                else { completion(false) ; return }
            
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let newUser = User(username: name, photo: photo, favoriteSpotsRefs: foodSpotsRefs, appleUserRef: reference)
            
            let userRecord = CKRecord(user: newUser)
            
            CloudKitManager.shared.save(record: userRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving new user to CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                guard let record = record,
                    let user = User(record: record) else { completion(false) ; return }
                
                self.loggedInUser = user
                completion(true)
            })
        }
    }
    
    // read
    func fetchUser(completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            guard let recordID = recordID else { completion(false) ; return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserConstants.appleUserRefKey, reference])
            
            CloudKitManager.shared.performFetch(recordType: UserConstants.typeKey, predicate: predicate, completion: { (records, error) in
                if let error = error {
                    print("Error fetching user from CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                guard let record = records?.first else { completion(false) ; return }
                
                let user = User(record: record)
                print("Fetched logged in user.")
                self.loggedInUser = user
                
                completion(true)
            })
        }
    }
    
    // update
    func update(user: User, withName name: String, photo: UIImage, foodSpots: [FoodSpot], completion: @escaping (Bool) -> Void) {
        user.photo = photo
        user.username = name
        user.favoriteSpots = foodSpots
        
        let updateRecord = CKRecord(user: user)
        
        CloudKitManager.shared.update(record: updateRecord) { (error) in
            if let error = error {
                print("Error updating user : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func update(user: User, with foodSpotRef: CKRecord.Reference, completion: @escaping (Bool) -> Void) {
        
        var userFoodSpotRefs = user.favoriteSpotsRefs ?? []
        userFoodSpotRefs.append(foodSpotRef)
        user.favoriteSpotsRefs = userFoodSpotRefs
        
        let updateRecord = CKRecord(user: user)
        
        CloudKitManager.shared.update(record: updateRecord) { (error) in
            if let error = error {
                print("Error updating user : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func remove(foodSpot: FoodSpot, fromUser user: User, completion: @escaping (Bool) -> Void) {
        guard let userFoodSpotRefs = user.favoriteSpotsRefs else { return }
        
        let foodSpotID = foodSpot.recordID
        let filtered = userFoodSpotRefs.filter{ $0.recordID != foodSpotID }
        user.favoriteSpotsRefs = filtered
        
        let updateRecord = CKRecord(user: user)
        
        CloudKitManager.shared.update(record: updateRecord) { (error) in
            if let error = error {
                print("Error updating user : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            print("FoodSpot removed from user successfully")
            FoodSpotController.shared.remove(user: user, fromFoodSpot: foodSpot, completion: { (success) in
                if success {
                    print("User removed from foodSpot successfully")
                }
            })
            
            completion(true)
        }
    }
    
    // delete
    func delete(user: User, completion: @escaping (Bool) -> Void) {
        
        let recordID = user.recordID
        
        CloudKitManager.shared.delete(record: recordID, completion: { (error) in
            if let error = error {
                print("Error deleting user from CloudKit : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
            self.loggedInUser = nil
            self.userFoodSpots = []
            completion(true)
        })
    }
}
