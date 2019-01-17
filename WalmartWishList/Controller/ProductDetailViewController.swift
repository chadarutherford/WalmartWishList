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
        guard let name = delegate?.item?.name else { return }
        guard let price = delegate?.item?.salePrice else { return }
        guard let productDescription = delegate?.item?.shortDescription else { return }
        guard let image = delegate?.item?.largeImage else { return }
        guard let available = delegate?.item?.availableOnline else { return }
        
        guard let url = URL(string: image) else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        
        productImageView.image = UIImage(data: imageData)
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productDescriptionTextView.text = "Description:\n \(productDescription)"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
        
        item = ItemObject(name: name, salePrice: price, shortDescription: productDescription, largeImage: image, availableOnline: available, isPurchased: false)
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
            itemsVC.selectedPerson?.items.append(item)
        default:
            break
        }
    }
}

