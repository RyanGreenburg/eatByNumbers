//
//  User.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/3/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

/// Custom User model object class
class User: CloudKitSyncable {
    /// The username provided by the user
    var username: String
    /// The data of the User's profile photo
    var photoData: Data?
    /// The User's profile photo
    var photo: UIImage {
        get {
            guard let photoData = self.photoData else { return UIImage(named: "stockPhoto")!}
            return UIImage(data: photoData)!
        }
        set {
            photoData = newValue.jpegData(compressionQuality: 1)
        }
    }
    /// The User's array of lists
    var lists: [List]
    
    // CloudKit properties
    static var recordType: CKRecord.RecordType {
        return UserConstants.typeKey
    }
    var ckRecord: CKRecord {
        let ckRecord = CKRecord(recordType: User.recordType, recordID: self.recordID)
        ckRecord.setValuesForKeys([
            UserConstants.usernameKey: self.username,
            UserConstants.photoKey: self.imageAsset,
            UserConstants.appleUserRefKey: self.appleUserRef
            ])
        return ckRecord
    }
    
    var appleUserRef: CKRecord.Reference
    var recordID: CKRecord.ID
    var imageAsset: CKAsset {
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
    
    init(username: String, photo: UIImage, lists: [List] = [], appleUserRef: CKRecord.Reference, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.username = username
        self.lists = lists
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
        self.lists = []
        
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
