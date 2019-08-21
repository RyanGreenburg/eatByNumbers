//
//  User.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class User: CloudKitSyncable {
    
    var username: String
    var photoData: Data?
    var favoriteSpots: [FoodSpot]?
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 1)
        }
    }
    
    // CloudKit properties
    static var recordType: CKRecord.RecordType {
        return UserConstants.typeKey
    }
    var ckRecord: CKRecord {
        let ckRecord = CKRecord(recordType: User.recordType, recordID: self.recordID)
        ckRecord.setValue(self.username, forKey: UserConstants.usernameKey)
        ckRecord.setValue(self.imageAsset, forKey: UserConstants.photoKey)
        ckRecord.setValue(self.favoriteSpotsRefs, forKey: UserConstants.favoriteSpotsRefKey)
        ckRecord.setValue(self.appleUserRef, forKey: UserConstants.appleUserRefKey)
        return ckRecord
    }
    
    var favoriteSpotsRefs: [CKRecord.Reference]?
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
    
    init(username: String, photo: UIImage, favoriteSpotsRefs: [CKRecord.Reference]?, appleUserRef: CKRecord.Reference?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.username = username
        self.favoriteSpotsRefs = favoriteSpotsRefs
        self.appleUserRef = appleUserRef
        self.recordID = recordID
        self.photo = photo
    }
    
    required init?(record: CKRecord) {
        guard let username = record[UserConstants.usernameKey] as? String,
            let appleUserRef = record[UserConstants.appleUserRefKey] as? CKRecord.Reference,
            let imageAsset = record[UserConstants.photoKey] as? CKAsset
            else { return nil }
        
        self.username = username
        self.appleUserRef = appleUserRef
        self.recordID = record.recordID
        self.favoriteSpotsRefs = record[UserConstants.favoriteSpotsRefKey] as? [CKRecord.Reference]
        
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
    static let favoriteSpotsRefKey = "favoriteSpotsRef"
    static let appleUserRefKey = "appleUserRef"
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
