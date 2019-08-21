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
        
        guard let reference = CloudKitManager.shared.fetchAppleUserReference() else { completion(false) ; return }
        let userToSave = User(username: name, photo: photo, favoriteSpotsRefs: foodSpotsRefs, appleUserRef: reference)
        
        CloudKitManager.shared.save(object: userToSave) { (result: Result<User, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            if case .success(let user) = result {
                print("Created user successfully")
                self.loggedInUser = user
                completion(true)
            }
        }
    }
    
    // read
    func fetchUser(completion: @escaping (Bool) -> Void) {
        
        guard let reference = CloudKitManager.shared.fetchAppleUserReference() else { completion(false) ; return }
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserConstants.appleUserRefKey, reference])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[User]?, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            if case .success(let users) = result {
                if let user = users?.first {
                    self.loggedInUser = user
                    completion(true)
                }
            }
        }
    }
    
    // update
    func update(user: User, withName name: String, photo: UIImage, foodSpots: [FoodSpot], completion: @escaping (Bool) -> Void) {
        user.photo = photo
        user.username = name
        user.favoriteSpots = foodSpots
        
        CloudKitManager.shared.update(user) { (result) in
            switch result {
            case .failure:
                print("Failed to update user to CloudKit")
                completion(false)
            case .success:
                print("Successfully updaed user")
                completion(true)
            }
        }
    }
    
    // delete
    func delete(user: User, completion: @escaping (Bool) -> Void) {
        
        if user.favoriteSpots != nil {
            for foodSpot in user.favoriteSpots! {
                FoodSpotController.shared.remove(user: user, fromFoodSpot: foodSpot) { (success) in
                    // handle
                }
            }
        }
        
        CloudKitManager.shared.delete(user) { (result) in
            switch result {
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            case .success(let success):
                if success {
                    print("Successfully deleted User from CloudKit")
                    completion(true)
                }
            }
        }
    }
}
