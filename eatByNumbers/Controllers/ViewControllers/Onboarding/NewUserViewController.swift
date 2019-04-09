//
//  NewUserViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {
    
    // MARK: - Properties
    var profilePhoto: UIImage?
    var user: User?
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let name = usernameTextField.text, !name.isEmpty,
            let photo = profilePhoto else { return }
        
        let newUser = User(username: name, photo: photo, favoriteSpots: nil, appleUserRef: nil)
        
        user = newUser
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoSelectSegue" {
            let destinationVC = segue.destination as? PhotoSelectorViewController
            destinationVC?.delegate = self
        }
        if segue.identifier == "toSelectSpotsVC" {
            let destinationVC = segue.destination as? SelectSpotsViewController
            destinationVC?.user = user
        }
    }
}

// MARK: - PhotoSelectDelegate
extension NewUserViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        self.profilePhoto = image
    }
}

//MARK: - UITextViewDelegate
extension NewUserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
