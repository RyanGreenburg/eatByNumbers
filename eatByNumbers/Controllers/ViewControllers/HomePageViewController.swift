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
    var foodSpots: [FoodSpot] = []
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var imHungryButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func imHungryButtonTapped(_ sender: Any) {
        
    }
    
    
    func updateViews() {
        guard let user = UserController.shared.loggedInUser else { return }
        self.user = user
        photoView.image = user.photo
        nameLabel.text = user.username
        foodSpots = UserController.shared.userFoodSpots
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

// MARK: - TableView DataSource/Delegate
extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodSpotcell", for: indexPath)
        let foodSpot = foodSpots[indexPath.row]
        
        cell.textLabel?.text = foodSpot.name
        
        return cell
    }
}

