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
    let version = URLQueryItem(name: "v", value: "20190101")
    let foodCategory = URLQueryItem(name: "categoryid", value: "4d4b7105d754a06374d81259")
    
    func searchWith(searchTerm: String?, location: String, completion: @escaping ([Venue]) -> Void) {
        guard var url = baseVenueURL else { completion([]) ; return }
        url.appendPathComponent("search")
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let userLocation = URLQueryItem(name: "ll", value: location)
        let total = URLQueryItem(name: "limit", value: "20")
        
        if searchTerm != nil {
            let search = URLQueryItem(name: "query", value: searchTerm)
            components?.queryItems = [id, key, userLocation, foodCategory, search, version]
        } else {
            components?.queryItems = [id, key, userLocation, total, foodCategory, version]
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
                let foundVenues = venueDictionary.response.venues
                completion(foundVenues ?? [])
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
                let suggestedVenues = venueDictionary.response.venues
                completion(suggestedVenues ?? [])
            } catch {
                print("Error decoding venues : \(error.localizedDescription) \n---\n\(error)")
                completion([])
            }
        }
        dataTask.resume()
    }
}
