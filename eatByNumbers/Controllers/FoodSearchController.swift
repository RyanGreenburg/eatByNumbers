//
//  FoodSearchController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/7/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class FoodSeachController {
    
    static let shared = FoodSeachController()
    
    let baseVenueURL = URL(string: "https://api.foursquare.com/v2/venues")
    let id = URLQueryItem(name: "client_id", value: "DGOFXPWHO1XRDWI511XMBMT5WSDYWYPEA4QZSFXG5LZCBYHR")
    let key = URLQueryItem(name: "client_secret", value: "FH44UMGJBJL3TFZ4KDC5JGJPXLGAH0AAT0W0DVNYEBCYRCTQ")
    let version = URLQueryItem(name: "v", value: "20190301")
    let foodCategory = URLQueryItem(name: "categoryid", value: "4d4b7105d754a06374d81259")
    
    func searchWith(searchTerm: String?, location: String, completion: @escaping (Set<Venue>) -> Void) {
        guard var url = baseVenueURL else { completion([]) ; return }
        url.appendPathComponent("explore")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let userLocation = URLQueryItem(name: "ll", value: location)
        
        if searchTerm != nil {
            let search = URLQueryItem(name: "query", value: searchTerm)
            components?.queryItems = [id, key, userLocation, foodCategory, search, version]
        } else {
            let search = URLQueryItem(name: "section", value: "food")
            components?.queryItems = [id, key, userLocation, search, version]
        }
        
        guard let componentsURL = components?.url else { completion([]) ; return }
        let request = URLRequest(url: componentsURL)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error downloading : \(error)")
                completion([])
                return
            }
            
            guard let data = data else { completion([]) ; return }
            
            do {
                let decoder = JSONDecoder()
                let venueDictionary = try decoder.decode(TopLevel.self, from: data)
                let venues = Set(venueDictionary.response.groups![0].items.compactMap({ $0.venue }))
                completion(venues)
            } catch {
                print("Error decoding venues : \(error.localizedDescription) \n---\n\(error)")
                completion([])
            }
        }
        dataTask.resume()
    }
    
    func suggestedCompletionSearchWith(searchTerm: String, location: String, completion: @escaping ([Venue]) -> Void) {
        guard var url = baseVenueURL else { completion([]) ; return }
        url.appendPathComponent("suggestcompletion")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let search = URLQueryItem(name: "query", value: searchTerm)
        let userLocation = URLQueryItem(name: "ll", value: location)
        components?.queryItems = [id, key, userLocation, foodCategory, search, version]
        
        guard let componentsURL = components?.url else { completion([]) ; return }
        let request = URLRequest(url: componentsURL)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error downloading : \(error)")
                completion([])
                return
            }
            
            guard let data = data else { completion([]) ; return }
            
            do {
                let decoder = JSONDecoder()
                let venueDictionary = try decoder.decode(TopLevel.self, from: data)
                let suggestedVenues = venueDictionary.response.minivenues
                completion(suggestedVenues ?? [])
            } catch {
                print("Error decoding venues : \(error.localizedDescription) \n---\n\(error)")
                completion([])
            }
        }
        dataTask.resume()
    }
    
    func searchByID(venueID: String, completion: @escaping (Venue?) -> Void) {
        guard var url = baseVenueURL else { completion(nil) ; return }
        
        url.appendPathComponent(venueID)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = [id, key, version]
        
        guard let componentsURL = components?.url else { completion(nil) ; return }
        print(componentsURL)
        
        let request = URLRequest(url: componentsURL)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error downloading : \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let decoder = JSONDecoder()
                let venueDictionary = try decoder.decode(TopLevel.self, from: data)
                let venue = venueDictionary.response.venue
                completion(venue)
            } catch {
                print("Error decoding venues : \(error.localizedDescription) \n---\n\(error)")
                completion(nil)
            }
        }
        dataTask.resume()
    }
}
