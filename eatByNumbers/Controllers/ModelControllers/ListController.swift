//
//  ListController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 9/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class ListController {
    
    static let shared = ListController()
    
    var userLists: [List]?
    
    // MARK: - CRUD
    
    // Create
    func createListWith(name: String, completion: @escaping (Bool) -> Void) {
        guard let userID = UserController.shared.loggedInUser?.recordID else { completion(false) ; return }
        let reference = CKRecord.Reference(recordID: userID, action: .deleteSelf)
        
        let newList = List(name: name, userReference: reference)
        CloudKitManager.shared.save(object: newList) { (result: Result<List, Error>) in
            // handle
        }
    }
    
    // Fetch
    func fetchListsForUser() {
        
    }
    
    // Update
    func update(list: List) {
        
    }
    
    // Delete
    func deleteList() {
        
    }
}
