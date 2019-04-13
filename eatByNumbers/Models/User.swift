//
//  User.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class User {
    
    var username: String
    var photoData: Data?
    var favoriteSpots: [FoodSpot]?
    var appleUserRef: CKRecord.Reference?
    var recordID: CKRecord.ID
    
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            do {
                try photoData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temporary url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 1)
        }
    }
    
    init(username: String, photo: UIImage, favoriteSpots: [FoodSpot]?, appleUserRef: CKRecord.Reference?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.username = username
        self.favoriteSpots = favoriteSpots
        self.appleUserRef = appleUserRef
        self.recordID = recordID
        self.photo = photo
    }
    
    init?(record: CKRecord) {
        guard let username = record[UserConstants.usernameKey] as? String,
            let appleUserRef = record[UserConstants.appleUserRefKey] as? CKRecord.Reference,
            let imageAsset = record[UserConstants.photoKey] as? CKAsset
            else { return nil }
        
        self.username = username
        self.appleUserRef = appleUserRef
        self.recordID = record.recordID
        self.favoriteSpots = record[UserConstants.favoriteSpotsKey] as? [FoodSpot]
        
        do {
            try self.photoData = Data(contentsOf: imageAsset.fileURL!)
        } catch {
            print("Error reading photo data from CKAsset : \(error.localizedDescription)")
        }
    }
}

// MARK: - Constants
struct UserConstants {
    
    static let typeKey = "User"
    
    static let usernameKey = "username"
    
    static let photoKey = "photo"
    
    static let favoriteSpotsKey = "favoriteSpots"
    
    static let appleUserRefKey = "appleUserRef"
}

// MARK: - CKRecord Extension
extension CKRecord {
    
    convenience init(user: User) {
        self.init(recordType: UserConstants.typeKey, recordID: user.recordID)
        
        setValue(user.username, forKey: UserConstants.usernameKey)
        setValue(user.imageAsset, forKey: UserConstants.photoKey)
        setValue(user.favoriteSpots, forKey: UserConstants.favoriteSpotsKey)
        setValue(user.appleUserRef, forKey: UserConstants.appleUserRefKey)
    }
}
