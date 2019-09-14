//
//  UserTests.swift
//  eatByNumbersTests
//
//  Created by RYAN GREENBURG on 9/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import XCTest
import CloudKit
@testable import eatByNumbers

class UserTests: XCTestCase {
    
    var sut: User?
    let ckManager = CloudKitManager()
    
    override func setUp() {
        super.setUp()
        guard let reference = ckManager.fetchAppleUserReference() else { return }
        sut = User(username: "Test User", photo: UIImage(named: "stockPhoto")!, appleUserRef: reference)
    }
    
    func testUserInit() {
        XCTAssertNotNil(sut, "User designated initializer functioning properlly")
    }
    
    func testUserCKRecord() {
        let record = sut!.ckRecord
        let name = record.object(forKey: UserConstants.usernameKey) as? String
        let reference = record.object(forKey: UserConstants.appleUserRefKey) as? CKRecord.Reference
        XCTAssert(name == sut?.username && reference == sut?.appleUserRef)
    }
    
    func testUserCKRecordInit() {
        let record = sut!.ckRecord
        let user = User(record: record)
        XCTAssertNotNil(user, "User ckRecord init fuctioning properlly")
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

