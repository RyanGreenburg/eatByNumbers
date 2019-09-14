//
//  ListTests.swift
//  eatByNumbersTests
//
//  Created by RYAN GREENBURG on 9/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit
import XCTest
@testable import eatByNumbers

class ListTests: XCTestCase {
    
    var sut: List?
    let ckManager = CloudKitManager()
    
    override func setUp() {
        super.setUp()
        guard let appleUserRef = ckManager.fetchAppleUserReference() else { return }
        let user = User(username: "Test User", photo: UIImage(named: "stockPhoto")!, appleUserRef: appleUserRef)
        let userRef = CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
        sut = List(name: "Test List", userReference: userRef)
    }
    
    func testListInit() {
        XCTAssertNotNil(sut, "List designated initializer test successful")
    }
    
    func testListCKRecord() {
        let record = sut!.ckRecord
        let name = record.object(forKey: ListStrings.nameKey) as? String
        let ref = record.object(forKey: ListStrings.userReferenceKey) as? CKRecord.Reference
        
        XCTAssert(name == sut?.name && ref == sut?.userReference)
    }
    
    func testListCKRecordInit() {
        let record = sut!.ckRecord
        let list = List(record: record)
        
        XCTAssertNotNil(list, "List CKRecord initalizer test successful")
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}
