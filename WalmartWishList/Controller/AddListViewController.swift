//
//  AddListViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/27/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import Seam3

class AddListViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }
    
    @IBAction func saveTapped(sender: UIButton) {
        guard let text = titleTextField.text else { return }
        let context = dataController.viewContext
        let newList = List(context: context)
        newList.title = text
        do {
            try context.save()
        } catch {
            let alert = UIAlertController(title: "Error", message: "There was an error creating a list: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func cancel(sender: UIButton) {
        dismiss(animated: true)
    }
}
