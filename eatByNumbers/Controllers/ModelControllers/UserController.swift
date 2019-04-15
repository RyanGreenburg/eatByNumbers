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
    func createUserWith(name: String, photo: UIImage, foodSpots: [FoodSpot]?, completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            guard let recordID = recordID
                else { completion(false) ; return }
            
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let newUser = User(username: name, photo: photo, favoriteSpots: foodSpots, appleUserRef: reference)
            
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
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            guard let recordID = recordID else { completion(false) ; return }
            
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let userToUpdate = User(username: name, photo: photo, favoriteSpots: foodSpots, appleUserRef: reference)
            
            let userRecord = CKRecord(user: userToUpdate)
            
            CloudKitManager.shared.save(record: userRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving new user to CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                guard let record = record,
                let user = User(record: record) else { completion(false) ; return }
                self.loggedInUser = user
                //  set user fav spots
                guard let foodSpots = self.loggedInUser?.favoriteSpots else { return }
                self.userFoodSpots = foodSpots
                completion(true)
            })
        }
    }
    
    func update(user: User, with foodSpots: [FoodSpot], completion: @escaping (Bool) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user AppleID : \(error.localizedDescription)")
                completion(false)
            }
            guard let photo = user.photo,
                let recordID = recordID
                else { completion(false) ; return }
            
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            let userToUpdate = User(username: user.username, photo: photo, favoriteSpots: foodSpots, appleUserRef: reference)
            
            let userRecord = CKRecord(user: userToUpdate)
            
            CloudKitManager.shared.save(record: userRecord, completion: { (record, error) in
                if let error = error {
                    print("Error saving new user to CloudKit : \(error.localizedDescription)")
                    completion(false)
                }
                guard let record = record,
                    let user = User(record: record) else { completion(false) ; return }
                self.loggedInUser = user
                //  set user fav spots
                guard let foodSpots = self.loggedInUser?.favoriteSpots else { return }
                self.userFoodSpots = foodSpots
                completion(true)
            })
        }
    }
    
    // delete
    func delete(user: User, completion: @escaping (Bool) -> Void) {
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
                self.loggedInUser = nil
                self.userFoodSpots = []
                completion(true)
            })
        }
    }
}
