//
//  FoodSearch.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/7/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import MapKit

struct TopLevel: Codable {
    let response: Response
}

struct Response: Codable {
    let venues: [Venue]?
    let groups: [Group]?
    let minivenues: [Venue]?
    let venue: Venue?
}

struct Venue: Codable {
    let name: String?
    let location: Location
    let categories: [Category]
    let id: String
}

extension Venue: Hashable {
    static func == (lhs: Venue, rhs: Venue) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

struct Location: Codable {
    let address: String?
    let lat: Double
    let lng: Double
    let distance: Int?
    let postalCode: String?
    let cc: String?
    let city: String?
    let state: String?
    let country: String?
}

struct Category: Codable {
    let name: String
    let id: String
    let pluralName: String
}

struct Group: Codable {
    let items: [Item]
}

struct Item: Codable {
    let venue: Venue
}

