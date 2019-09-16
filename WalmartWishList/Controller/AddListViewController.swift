//
//  AddListViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/27/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

class AddListViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    weak var delegate: AddListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    }
    
    @IBAction func saveTapped(sender: UIButton) {
        guard let title = titleTextField.text else { return }
        delegate?.saveList(withTitle: title)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismiss(animated: true)
    }
}
