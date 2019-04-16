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
        setupViews()
        foundFoodSpotsLabel.text = "Working"
        foundUserLabel.text = "Working"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserController.shared.fetchUser { (success) in
            if success {
                self.didFindUser()
                self.fetchFoodSpots()
            } else {
                self.fetchFoodSpots()
                self.goToUserCreation()
            }
        }
    }
    
    func fetchVenues() {
        guard let userLocation = UserController.shared.userLocationManager?.location
            else { return }
        let userLocationString = "\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
        FoodSeachController.shared.searchWith(searchTerm: nil, location: userLocationString) { (foundVenues) in
            FoodSpotController.shared.nearbyVenues = foundVenues
        }
    }
    
    func fetchFoodSpots() {
        FoodSpotController.shared.fetchSpots(completion: { (success) in
            if success {
                self.didFindFoodSpots()
                self.fetchVenues()
                self.goToMainApp()
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
            let storyboard = UIStoryboard(name: "MapView", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "FindSpotsVC")
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}

extension InitialViewController {
    func setupViews() {
        activityIndicator.color = Colors.lightBlue.color()
        self.view.backgroundColor = Colors.lightGray.color()
        fetchingUserLabel.textColor = Colors.white.color()
        fetchingFoodSpotsLabel.textColor = Colors.white.color()
        foundUserLabel.textColor = Colors.lightBlue.color()
        foundFoodSpotsLabel.textColor = Colors.lightBlue.color()
    }
}
