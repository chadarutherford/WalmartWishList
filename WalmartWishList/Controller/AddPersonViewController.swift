//
//  AddPersonViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase
import PhotosUI

final class AddPersonViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    // MARK: - Properties
    private var imagePicker = UIImagePickerController()
    private var imageData = Data()
    private var imageURL = ""
    var list: List?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageButton.isHidden = false
        profileImageButton.isEnabled = true
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }
    
    // MARK: - Helper Methods
    func storeImageAsUrl(name: String) {
        let imageRef = DatabaseRefs.photos.child("/WishList/\(name)/userImages/\(name).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metaData) { metaData, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                guard let url = url else { return }
                self.uploadDocument(name: name, url: url.absoluteString)
            }
        }
    }
    
    func uploadDocument(name: String, url: String) {
        let person = Person(name: name, image: url, itemCount: 0, items: [])
        list?.people.append(person)
        let docData = try! FirestoreEncoder().encode(list)
        guard let list = list else { return }
        DatabaseRefs.wishlists.document(list.documentID).updateData(docData)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        storeImageAsUrl(name: name)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - View Controller Extension
extension AddPersonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UIImagePickerController Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                switch newStatus {
                case .authorized:
                    break
                default:
                    break
                }
            }
        case .restricted, .denied:
            displayAlert(title: "Photo Library Access Error", message: "Please check settings and enable Photo Library acces")
        case .authorized:
            break
        default:
            break
        }
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            personImageView.image = pickedImage
            profileImageButton.isHidden = true
            if let data = pickedImage.jpegData(compressionQuality: 0.75) {
                imageData = data
            }
        }
        dismiss(animated: true)
    }
}
