//
//  SignupViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Helper Methods
    func showError(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func signUpUser(completion: @escaping (Bool, Error?) -> ()) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let _ = result {
                self?.loginUser { success, error in
                    completion(true, nil)
                }
            } else {
                guard let error = error else { return }
                self?.showError(message: error.localizedDescription)
                completion(false, error)
            }
        }
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
    @IBAction func signUpTapped(_ sender: UIButton) {
        spinner.startAnimating()
        signUpUser { [weak self] success, error in
            if success {
                self?.performSegue(withIdentifier: SegueConstant.signedUp, sender: self)
                self?.spinner.stopAnimating()
            }
        }
    }
}
