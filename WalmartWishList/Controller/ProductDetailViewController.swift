//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/16/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

protocol ItemDelegate {
    var item: ItemObject? { get set }
}

class ProductDetailViewController: UIViewController, ItemDelegate {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAvailableLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    
    var delegate: ItemDelegate?
    var item: ItemObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProduct()
    }
    
    private func loadProduct() {
        guard let name = delegate?.item?.name, let price = delegate?.item?.salePrice, let productDescription = delegate?.item?.shortDescription, let imageURLString = delegate?.item?.largeImage, let available = delegate?.item?.availableOnline else { return }
        guard let url = URL(string: imageURLString) else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        productImageView.image = UIImage(data: imageData)
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productDescriptionTextView.text = "Description:\n \(productDescription)"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
