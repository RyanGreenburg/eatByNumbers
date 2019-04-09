//
//  EditProfileViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    
    @IBOutlet weak var photoContainerView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var deleteProfileButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteProfileButtonTapped(_ sender: Any) {
        // Delete the user and relaunch the app.
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        // save the changes to the user and pop the view.
    }
    
}
