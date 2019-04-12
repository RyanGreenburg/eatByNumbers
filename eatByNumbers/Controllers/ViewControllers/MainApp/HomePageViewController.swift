//
//  HomePageViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    
    var user: User?
    var userFoodSpots: [FoodSpot] = []
    var foodSpots: [FoodSpot] {
        return FoodSpotController.shared.nearbyFoodSpots
    }
    var venues: [Venue] {
        return FoodSpotController.shared.nearbyVenues
    }
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var imHungryButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func imHungryButtonTapped(_ sender: Any) {
        
    }
    
    
    func updateViews() {
        guard let user = UserController.shared.loggedInUser else { return }
        self.user = user
        photoView.image = user.photo
        nameLabel.text = user.username
        userFoodSpots = UserController.shared.userFoodSpots
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFindSpotsVC" {
            let destinationVC = segue.destination as? FindSpotsViewController
        }
    }
}

// MARK: - TableView DataSource/Delegate
extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFoodSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodSpotcell", for: indexPath)
        let foodSpot = userFoodSpots[indexPath.row]
        
        cell.textLabel?.text = foodSpot.name
        
        return cell
    }
}

