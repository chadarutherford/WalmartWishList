//
//  ItemDetailViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController, ItemDelegate {

    // MARK: - Outlets
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    // MARK: - Properties
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
        guard let image = delegate?.item?.thumbnailImage else { return }
        
        itemImageView.image = UIImage(data: image)
        itemNameLabel.text = name
        itemPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        
    }
}
