//
//  InitialViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CoreLocation

class InitialViewController: UIViewController {
    
    var isUser = false
    var foundFoodSpots = false

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fetchingUserLabel: UILabel!
    @IBOutlet weak var foundUserLabel: UILabel!
    @IBOutlet weak var fetchingFoodSpotsLabel: UILabel!
    @IBOutlet weak var foundFoodSpotsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foundFoodSpotsLabel.text = "Working"
        foundUserLabel.text = "Working"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserController.shared.fetchUser { (success) in
            if success {
                self.didFindUser()
                self.fetchFoodSpots()
                self.goToMainApp()
            } else {
                self.fetchFoodSpots()
                self.goToUserCreation()
            }
        }
    }
    
    func fetchFoodSpots() {
        FoodSpotController.shared.fetchSpots(completion: { (success) in
            if success {
                self.didFindFoodSpots()
            }
        })
    }
    
    func fetchUser() {
        UserController.shared.fetchUser { (success) in
            if success {
                self.didFindUser()
                self.goToMainApp()
            } else {
                // create new user page
                self.goToUserCreation()
            }
        }
    }

    func didFindFoodSpots() {
        DispatchQueue.main.async {
            self.foundFoodSpots = true
            self.foundFoodSpotsLabel.text = "Success"
        }
    }
    
    func didFindUser() {
        DispatchQueue.main.async {
            self.isUser = true
            self.foundUserLabel.text = "Success"
            UserController.shared.userLocationManager = CLLocationManager()
        }
    }
    
    func goToUserCreation() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "NewUser", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "NewUserNavController")
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func goToMainApp() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "HomePageNavController")
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
