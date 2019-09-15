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
    func saveFoodSpot(withName name: String, id: String, address: String, location: CLLocation, to list: List, completion: @escaping (Bool) -> Void) {
        
        let reference = [CKRecord.Reference(recordID: list.recordID, action: .deleteSelf)]
        let newFoodSpot = FoodSpot(id: id, name: name, address: address, location: location, listReferences: reference)
        
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
    
    func addExisting(_ foodSpot: FoodSpot, to list: List, completion: @escaping (Bool) -> Void) {
        
        let foodSpotRefs = foodSpot.listReferences.compactMap({ $0.recordID })
        if foodSpotRefs.contains(list.recordID) {
            completion(false)
            return
        } else {
            let newRef = CKRecord.Reference(recordID: list.recordID, action: .deleteSelf)
            foodSpot.listReferences.append(newRef)
            self.update(foodSpot: foodSpot) { (success) in
                print("Successfully saved existing FoodSpot to list.")
                completion(true)
            }
        }
    }
    
    func checkFoodSpotStatus(name: String, for list: List, completion: @escaping (Bool) -> Void) {

        let predicate = NSPredicate(format: "name == %@", name)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[FoodSpot]?, Error>) in
            switch result{
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            case .success(let foodSpots):
                print("FoodSpot exists")
                if let foodSpot = foodSpots?.first {
                    self.addExisting(foodSpot, to: list, completion: { (success) in
                        if success {
                            // handle
                        }
                    })
                }
            }
        }
    }
    
    // read
    func fetchSpots(with compoundPredicate: NSCompoundPredicate, completion: @escaping ([FoodSpot]?) -> Void) {
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[FoodSpot]?, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
            
            if case .success(let foodSpots) = result {
                // Set the FoodSpot source of truth
                guard let foodSpots = foodSpots, !foodSpots.isEmpty else { completion(nil) ; return }
                print("Fetched foodSpots Successfully")
                completion(foodSpots)
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
