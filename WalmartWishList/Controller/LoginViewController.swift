//
//  LoginViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = Auth.auth().currentUser {
            performSegue(withIdentifier: SegueConstant.loggedIn, sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func loginUser(completion: @escaping (Bool, Error?) -> ()) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let _ = result {
                completion(true, nil)
            } else {
                guard let error = error else { return }
                self?.showError(message: error.localizedDescription)
                completion(false, error)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        spinner.startAnimating()
        loginUser { [weak self] success, error in
            if success {
                let storyboard = UIStoryboard(name: Storyboard.listSelection, bundle: nil)
                guard let listSelectionVC = storyboard.instantiateViewController(withIdentifier: StoryboardIDs.listSelection) as? ListSelectionViewController else { return }
                self?.present(listSelectionVC, animated: true)
                self?.spinner.stopAnimating()
            }
        }
    }
}
