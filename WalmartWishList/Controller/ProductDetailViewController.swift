//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

protocol ItemDelegate {
    var item: ItemObject { get set }
}

class ProductDetailViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAvailableLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var wishListButton: UIButton!
    
    // MARK: - Properties
    var delegate: ItemDelegate?
    var item = ItemObject()
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProduct()
    }
    
    // MARK: - Helper Methods
    func loadProduct() {
        guard let name = delegate?.item.name else { return }
        item.name = name
        guard let price = delegate?.item.salePrice else { return }
        item.salePrice = price
        guard let available = delegate?.item.availableOnline else { return }
        item.availableOnline = available
        guard let productDescription = delegate?.item.shortDescription else { return }
        item.shortDescription = productDescription
        
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
        productDescriptionTextView.text = "Description:\n \(productDescription)"
    }
    
    // MARK: - Actions
    @IBAction func wishListButtonTapped(_ sender: UIButton) {
        guard let itemsVC = UIViewController() as? ListItemViewController else { return }
        itemsVC.delegate = self
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
