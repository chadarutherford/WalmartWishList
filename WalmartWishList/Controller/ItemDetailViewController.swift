//
//  ItemDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift

class ItemDetailViewController: UIViewController, ItemDelegate {

    // MARK: - Outlets
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    // MARK: - Properties
    let realm = try! Realm()
    var delegate: ItemDelegate?
    var item: ItemObject?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProduct()
    }
    
    // MARK: - Helper Methods
    func loadProduct() {
        guard let name = delegate?.item?.name else { return }
        guard let price = delegate?.item?.salePrice else { return }
        guard let description = delegate?.item?.shortDescription else { return }
        guard let image = delegate?.item?.thumbnailImage else { return }
        guard let available = delegate?.item?.availableOnline else { return }
        guard let purchased = delegate?.item?.isPurchased else { return }
        
        item = ItemObject(name: name, salePrice: price, shortDescription: description, thumbnailImage: image, availableOnline: available, isPurchased: purchased)
        
        itemImageView.image = UIImage(data: image)
        itemNameLabel.text = name
        itemPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        do {
            try realm.write {
                guard let item = item else { return }
                item.isPurchased = true
            }
        } catch let error {
            print(error)
        }
        dismiss(animated: true)
    }
}
