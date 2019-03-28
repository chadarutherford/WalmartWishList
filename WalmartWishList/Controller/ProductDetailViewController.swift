//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

protocol ItemDelegate {
    var item: ItemObject? { get set }
}

final class ProductDetailViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAvailableLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var wishListButton: UIButton!
    
    // MARK: - Properties
    var delegate: ItemDelegate?
    var item: ItemObject?
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProduct()
    }
    
    // MARK: - Helper Methods
    private func loadProduct() {
    }
    
    // MARK: - Actions
    @IBAction func wishListButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueConstant.unwindToListItem, sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.unwindToListItem:
            guard let itemsVC = segue.destination as? ListItemViewController else { return }
            itemsVC.delegate = self
            guard let item = item else { return }
        default:
            break
        }
    }
}

