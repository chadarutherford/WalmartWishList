//
//  ProductDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

final class ProductDetailViewController: UIViewController, PersistentContainerRequiring, CloudStoreRequiring {
    
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
    var cloudStore: CloudStore!
    var item: SearchItem?
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProduct()
    }
    
    // MARK: - Helper Methods
    private func loadProduct() {
        guard let name = item?.name else { return }
        guard let price = item?.salePrice else { return }
        guard let productDescription = item?.shortDesc else { return }
        guard let image = item?.largeImage else { return }
        guard let available = item?.availableOnline else { return }
        productImageView.image = UIImage(data: image)
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productDescriptionTextView.text = "Description:\n \(String(htmlEncodedString: productDescription))"
        productAvailableLabel.text = "Available Online: \(available ? "Yes" : "No")"
    }
    
    // MARK: - Actions
    @IBAction func wishListButtonTapped(_ sender: UIButton) {
        let moc = persistentContainer.viewContext
        moc.persist {
            guard let price = self.item?.salePrice, let available = self.item?.availableOnline, let purchased = self.item?.isPurchased else { return }
            
            let newItem = ItemObject.find(byName: self.item?.name ?? "", orCreateIn: moc)
            newItem.name = self.item?.name
            newItem.recordName = UUID().uuidString
            newItem.salePrice = price
            newItem.largeImage = self.item?.largeImage
            newItem.shortDesc = self.item?.shortDesc
            newItem.availableOnline = available
            newItem.isPurchased = purchased
            newItem.person = self.person
            
            let newItems: Set<AnyHashable> = self.person.items?.adding(newItem) ?? [newItem]
            self.person.items = NSSet(set: newItems)
            
            self.cloudStore.storePerson(self.person) { _ in
                
            }
        }
        performSegue(withIdentifier: SegueConstant.unwindToListItem, sender: self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

