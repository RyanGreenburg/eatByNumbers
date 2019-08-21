//
//  PhotoSelectorViewController.swift
//  eatByNumbers
//
//  Created by RYAN GREENBURG on 4/4/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class PhotoSelectorViewController: UIViewController, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var user: User?
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupViews()
    }
    
    @IBAction func selectButtonTapped(_ sender: Any) {
        let alert = AlertHelper.shared.blankAlertController("Add Profile Photo", andText: "")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openGallery()
        }
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoSelectorViewController: UIImagePickerControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Camera Access", message: "Please allow access to the camera to use this feature.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Photos Access", message: "Please allow access to Photos to use this feature.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let delegate = delegate
                else { return }
            delegate.photoSelectorViewControllerSelected(image: pickedImage)
            photoView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoSelectorViewController {
    func setupViews() {
        self.view.backgroundColor = .clear
        if let photo = user?.photo {
            photoView.image = photo
        } else {
            photoView.image = UIImage(named: "stockPhoto")
        }
        photoView.layer.cornerRadius = photoView.frame.width / 2
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        buttonView.layer.cornerRadius = buttonView.frame.width / 2
        buttonView.clipsToBounds = true
        selectButton.backgroundColor = Colors.lightBlue.color()
        selectButton.setTitleColor(Colors.white.color(), for: .normal)
        selectButton.alpha = 0.75
    }
}

protocol PhotoSelectorViewControllerDelegate: class {
    func photoSelectorViewControllerSelected(image: UIImage)
}
