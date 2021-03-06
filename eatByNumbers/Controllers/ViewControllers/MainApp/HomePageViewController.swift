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
    var resultsController: UISearchController?
    var userFoodSpots: [FoodSpot] = [] 
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name("userFoodSpotsChanged"), object: nil)
        setSearchController()
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("userFoodSpotsChanged"), object: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        // go to user edit page.
    }
    
    func setSearchController() {
        let storyboard = UIStoryboard(name: "SelectFavSpots", bundle: nil)
        let locationsTVC = storyboard.instantiateViewController(withIdentifier: "locationsTableViewController") as? LocationsTableViewController
        resultsController = UISearchController(searchResultsController: locationsTVC)
        resultsController?.searchResultsUpdater = locationsTVC
        let searchBar = resultsController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for food spots"
        navigationItem.titleView = resultsController?.searchBar
        resultsController?.hidesNavigationBarDuringPresentation = false
        resultsController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationsTVC?.tableView.tableFooterView = UIView()
        locationsTVC?.tableView.tableFooterView?.backgroundColor = .clear
    }
    
    @objc func reloadTableView() {
        userFoodSpots = UserController.shared.userFoodSpots
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateViews() {
        guard let user = UserController.shared.loggedInUser,
            let photo = UserController.shared.loggedInUser?.photo
            else { return }
        self.user = user
        self.photoView.image = photo
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.layer.cornerRadius = photoView.frame.width / 2
        nameLabel.text = user.username
        userFoodSpots = UserController.shared.userFoodSpots
        tableView.reloadData()
    }
    
    func setViews() {
        self.view.backgroundColor = Colors.lightGray.color()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = .clear
        tableView.backgroundColor = .clear
        nameLabel.textColor = Colors.white.color()
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVC" {
            let destinationVC = segue.destination as? EditProfileTableViewController
            destinationVC?.user = self.user
            destinationVC?.foodSpots = self.userFoodSpots
        }
    }
}

// MARK: - TableView DataSource/Delegate
extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFoodSpots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodSpotCell", for: indexPath)
        let foodSpot = userFoodSpots[indexPath.row]
        
        cell.textLabel?.text = foodSpot.name
        cell.detailTextLabel?.text = foodSpot.address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let spotToRemove = userFoodSpots[indexPath.row]
            userFoodSpots.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if let user = user {
                FoodSpotController.shared.remove(user: user, fromFoodSpot: spotToRemove) { (success) in
                    UserController.shared.userFoodSpots = self.userFoodSpots
                }
            }
        }
    }
}
