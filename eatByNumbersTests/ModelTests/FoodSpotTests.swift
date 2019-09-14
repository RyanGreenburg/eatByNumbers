//
//  FoodSpotTests.swift
//  eatByNumbersTests
//
//  Created by RYAN GREENBURG on 9/14/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import XCTest
@testable import eatByNumbers

class FoodSpotTests: XCTestCase {
    
    var sut: FoodSpot?
    
    override func setUp() {
        super.setUp()
        let location = CLLocation(latitude: 0, longitude: 0)
        let refs = CKRecord.Reference(record: CKRecord(recordType: "TestType"), action: .deleteSelf)
        
        sut = FoodSpot(id: "Test ID", name: "Test Name", address: "Test Address", location: location, listReferences: [refs], recordID: CKRecord.ID(recordName: UUID().uuidString))
    }
    
    func testFoodSpotInit() {
        XCTAssertNotNil(sut, "FoodSpot designated intitalizer successful")
    }
    
    func testFoodSpotCKRecord() {
        let record = sut!.ckRecord
        let id = record.object(forKey: FoodSpotConstants.idKey) as? String
        let name = record.object(forKey: FoodSpotConstants.nameKey) as? String
        let address = record.object(forKey: FoodSpotConstants.addressKey) as? String
        let references = record.object(forKey: FoodSpotConstants.referenceKey) as? [CKRecord.Reference]
        
        XCTAssert(id == sut?.id && name == sut?.name && address == sut?.address && references == sut?.listReferences)
    }
    
    func testFoodSpotCKRecordInit() {
        let record = sut!.ckRecord
        let foodSpot = FoodSpot(record: record)
        
        XCTAssertNotNil(foodSpot, "FoodSpot CKRecord initializer successful")
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}
