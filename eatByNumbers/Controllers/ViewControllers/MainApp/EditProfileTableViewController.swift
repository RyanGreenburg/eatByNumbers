//
//  EditProfileTableViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/16/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, PhotoSelectorViewControllerDelegate {
    
    var user = UserController.shared.loggedInUser
    var photo: UIImage?
    var foodSpots = UserController.shared.userFoodSpots

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextfField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = user else { return }
        usernameTextfField.text = user.username
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let user = user,
            let name = usernameTextfField.text,
            let photo = photo
            else { return }
        
        UserController.shared.update(user: user, withName: name, photo: photo, foodSpots: foodSpots) { (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        guard let user = user else { return }
        let alert = AlertHelper.shared.blankAlertController("Delete Profile?", andText: "Deleting your profile will remove any information associated with it.")
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (delete) in
            UserController.shared.delete(user: user, completion: { (success) in
                if success {
                    self.restartApp()
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func photoSelectorViewControllerSelected(image: UIImage) {
        self.photo = image
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSelectSegue" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
            destinationVC?.user = user
        }
    }
    
    func restartApp() {
        let viewController = InitialViewController()
        let navControl = UINavigationController(rootViewController: viewController)
        
        guard let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController else { return }
        
        navControl.view.frame = rootViewController.view.frame
        navControl.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil) { (success) in
            if success {
                window.rootViewController = navControl
            }
        }
    }
}
