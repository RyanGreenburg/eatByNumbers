//
//  NewUserViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CoreLocation

class NewUserViewController: UIViewController {
    
    // MARK: - Properties
    var profilePhoto: UIImage?
    var user: User?
    let locationManager = CLLocationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var allowLocationButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.delegate = self
        setupViews()
    }
    
    // MARK: - Actions
    @IBAction func allowLocationButtonTapped(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let name = usernameTextField.text, !name.isEmpty,
            let photo = profilePhoto else { return }
        
        let newUser = User(username: name, photo: photo, favoriteSpotsRefs: nil, appleUserRef: nil)
        user = newUser
        UserController.shared.createUserWith(name: name, photo: photo, foodSpotsRefs: nil) { (success) in
            if success {
                print("User Created Successfully")
            }
        }
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MapView", bundle: nil)
        guard let viewController = storyboard.instantiateInitialViewController() else { return }
        
        present(viewController, animated: true, completion: nil)
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
        if segue.identifier == "toMapVC" {
            let _ = segue.destination as? FindSpotsViewController
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

extension NewUserViewController {
    func setupViews() {
        self.view.backgroundColor = Colors.lightGray.color()
        backgroundView.backgroundColor = Colors.lightGray.color()
        allowLocationButton.backgroundColor = Colors.lightBlue.color()
        allowLocationButton.setTitleColor(Colors.white.color(), for: .normal)
        allowLocationButton.layer.cornerRadius = allowLocationButton.frame.height / 4
        usernameLabel.textColor = Colors.white.color()
        addPhotoLabel.textColor = Colors.white.color()
        skipButton.backgroundColor = Colors.lightBlue.color()
        skipButton.setTitleColor(Colors.darkGray.color(), for: .normal)
        skipButton.layer.cornerRadius = skipButton.frame.height / 4
        nextButton.backgroundColor = Colors.lightBlue.color()
        nextButton.setTitleColor(Colors.white.color(), for: .normal)
        nextButton.layer.cornerRadius = nextButton.frame.height / 4
        usernameTextField.backgroundColor = Colors.white.color()
        usernameTextField.textColor = Colors.darkGray.color()
        containerView.layer.cornerRadius = containerView.frame.width / 2
    }
}
