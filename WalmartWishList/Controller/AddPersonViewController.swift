//
//  AddPersonViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

protocol PersonDelegate {
    func convertInputToPerson(name: String, image: Data)
}

final class AddPersonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    var delegate: PersonDelegate?
    private var imagePicker = UIImagePickerController()
    private var imageData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        imageContainerView.isHidden = false
        profileImageButton.isEnabled = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            personImageView.image = pickedImage
            imageContainerView.isHidden = true
            if let data = pickedImage.jpegData(compressionQuality: 0.75) {
                imageData = data
            }
        }
        dismiss(animated: true)
    }
    
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let delegate = delegate else { return }
        guard let name = nameTextField.text else { return }
        delegate.convertInputToPerson(name: name, image: imageData)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
