//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift

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
    let realm = try! Realm()
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
        guard let productDescription = delegate?.item.shortDescription else { return }
        item.shortDescription = productDescription
        guard let image = delegate?.item.thumbnailImage else { return }
        item.thumbnailImage = image
        guard let available = delegate?.item.availableOnline else { return }
        item.availableOnline = available
        
        productImageView.image = UIImage(data: image)
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productDescriptionTextView.text = "Description:\n \(productDescription)"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
        
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
            do {
                try realm.write {
                    itemsVC.selectedPerson?.items.append(item)
                }
            } catch let error {
                print(error)
            }
        default:
            break
        }
    }
}
