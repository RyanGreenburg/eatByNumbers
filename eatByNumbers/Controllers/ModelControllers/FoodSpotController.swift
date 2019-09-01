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
    var allFoodSpots: Set<FoodSpot> = [] {
        didSet {
            guard let userLocation = UserController.shared.userLocationManager?.location
                else { return }
            nearbyFoodSpots = allFoodSpots.filter({ $0.location.distance(from: userLocation) <= 80467 })
        }
    }
    
    // spots within 50 miles of the user
    var nearbyFoodSpots: Set<FoodSpot> = []
    
    // API Call
    var nearbyVenues: Set<Venue> = []
    
    // MARK: - CRUD
    
    // save
    func saveFoodSpot(withName name: String, id: String, address: String, location: CLLocation, completion: @escaping (Bool) -> Void) {
        
        guard let recordID = UserController.shared.loggedInUser?.recordID else { completion(false) ; return }
        
        let reference = [CKRecord.Reference(recordID: recordID, action: .deleteSelf)]
        let newFoodSpot = FoodSpot(id: id, name: name, address: address, location: location, usersFavoriteReferences: reference)
        
        CloudKitManager.shared.save(object: newFoodSpot, completion: { (result: Result<FoodSpot, Error>) in
            
            if case .failure(let error) = result{
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
            
            if case .success(let foodSpot) = result {
                print("Saved FoodSpot to CloudKit")
                self.allFoodSpots.insert(foodSpot)
                UserController.shared.userFoodSpots.append(foodSpot)
                completion(true)
            }
        })
    }
    
    func checkFoodSpotStatus(name: String, completion: @escaping (Bool) -> Void) {
        
        guard let user = UserController.shared.loggedInUser else { completion(false) ; return }
        let predicate = NSPredicate(format: "name == %@", name)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[FoodSpot]?, Error>) in
            switch result{
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            case .success(let foodSpots):
                print("FoodSpot exists")
                if let foodSpot = foodSpots?.first {
                    let reference = CKRecord.Reference(recordID: user.recordID, action: .none)
                    if foodSpot.usersFavoriteReferences.contains(reference) {
                        completion(false)
                        return
                    } else {
                        foodSpot.usersFavoriteReferences.append(reference)
                        self.update(foodSpot: foodSpot, completion: { (success) in
                            if success {
                                completion(true)
                            }
                        })
                    }
                } else {
                    completion(false)
                    return
                }
            }
        }
    }
    
    // read
    func fetchSpots(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[FoodSpot]?, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
            
            if case .success(let foodSpots) = result {
                // Set the FoodSpot source of truth
                guard let foodSpots = foodSpots, !foodSpots.isEmpty else { completion(false) ; return }
                self.allFoodSpots = Set(foodSpots)
                
                // Set the user's foodSpots
                guard let userID = UserController.shared.loggedInUser?.recordID else { completion(false) ; return }
                let userFoodSpots = self.allFoodSpots.filter{( $0.usersFavoriteReferences.contains{( $0.recordID == userID)} )}
                UserController.shared.userFoodSpots = Array(userFoodSpots)
                completion(true)
            }
        }
    }
    
    // update
    func update(foodSpot: FoodSpot, completion: @escaping (Bool) -> Void) {
        CloudKitManager.shared.update(foodSpot) { (result: Result<FoodSpot, Error>) in
            switch result{
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            case .success:
                completion(true)
            }
        }
    }
    
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
            CloudKitManager.shared.update(foodSpot) { (result: Result<FoodSpot, Error>) in
                switch result{
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                case .success(let foodSpot):
                    print("Successfully revomed FoodSpot: \(foodSpot.recordID) from User: \(user.recordID)")
                    completion(true)
                }
            }
        }
    }
    
    // delete
    func delete(foodSpot: FoodSpot, completion: @escaping (Bool) -> Void) {
        
        CloudKitManager.shared.delete(foodSpot) { (result) in
            switch result{
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            case .success:
                print("Successfully deleted FoodSpot from CloudKit")
                completion(true)
            }
        }
    }
}
