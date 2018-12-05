//
//  AddPersonViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

protocol PersonDelegate {
    func convertInputToPerson(name: String, image: String)
}

class AddPersonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var popupView: UIView!
    
    var imagePicker = UIImagePickerController()
    var delegate: PersonDelegate?
    var imageString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        imageContainerView.isHidden = false
        
        profileImageButton.isEnabled = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let date = Date()
        let uuidString = UUID().uuidString
        imageString = "\(uuidString) \(date)"
        guard let imagePath = documentsPath?.appendingPathComponent("\(imageString).jpg") else { return }
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            personImageView.image = pickedImage
            imageContainerView.isHidden = true
            guard let imageData = pickedImage.jpegData(compressionQuality: 0.75) else { return }
            do {
                try imageData.write(to: imagePath, options: .atomic)
            } catch let error {
                print(error)
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
        
        
        delegate.convertInputToPerson(name: name, image: imageString)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
