//
//  AddPersonViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import PhotosUI

final class AddPersonViewController: UIViewController, PersistentContainerRequiring {
    
    // MARK: - Outlets
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    // MARK: - Properties
    private var imagePicker = UIImagePickerController()
    private var imageData = Data()
    var persistentContainer: NSPersistentContainer!
    var list: List!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageButton.isHidden = false
        profileImageButton.isEnabled = true
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }
    
    // MARK: - Helper Methods
    
    // MARK: - Actions
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        let moc = persistentContainer.viewContext
        moc.persist { [weak self] in
            let person = Person.find(byName: name, orCreateIn: moc)
            if person.name == nil || person.name?.isEmpty == true {
                person.name = name
            }
            person.image = self?.imageData
            let newPeople: Set<AnyHashable> = self?.list.people?.adding(person) ?? [person]
            self?.list.people = NSSet(set: newPeople)
        }
        self.dismiss(animated: true)
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
            break
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
