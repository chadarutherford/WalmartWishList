//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

final class ProductDetailViewController: UIViewController, PersistentContainerRequiring {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAvailableLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var wishListButton: UIButton!
    
    // MARK: - Properties
    var person: Person!
    var persistentContainer: NSPersistentContainer!
    var item: SearchItem?
    var newItem: ItemObject?
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProduct()
    }
    
    // MARK: - Helper Methods
    private func loadProduct() {
        guard let name = item?.name else { return }
        guard let price = item?.salePrice else { return }
        guard let productDescription = item?.shortDesc.removingPercentEncoding else { return }
        guard let image = item?.largeImage else { return }
        guard let available = item?.availableOnline else { return }
        let context = persistentContainer.viewContext
        newItem = ItemObject(context: context)
        newItem?.name = name
        newItem?.salePrice = price
        newItem?.largeImage = image
        newItem?.shortDesc = productDescription
        newItem?.availableOnline = available
        newItem?.isPurchased = false
        newItem?.person = person
        productImageView.image = UIImage(data: image)
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productDescriptionTextView.text = "Description:\n \(productDescription)"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
    }
    
    // MARK: - Actions
    @IBAction func wishListButtonTapped(_ sender: UIButton) {
        let moc = persistentContainer.viewContext
        moc.persist {
            var item = ItemObject.find(byName: self.newItem?.name ?? "", orCreateIn: moc)
            item = self.newItem ?? ItemObject(context: moc)
            
            let newItems: Set<AnyHashable> = self.person.items?.adding(item) ?? [item]
            self.person.items = NSSet(set: newItems)
        }
        performSegue(withIdentifier: SegueConstant.unwindToListItem, sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

