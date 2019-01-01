//
//  ItemsCell.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

final class ItemsCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemAvailableLabel: UILabel!
    
    func configure(withImage image: UIImage, withName name: String, withPrice price: Double, withAvailability availability: Bool) {
        itemImageView.image = image
        itemNameLabel.text = name
        itemPriceLabel.text = String(format: "$%.2f", price)
        itemAvailableLabel.text = "Available Online: \(availability ? "Yes" : "No")"
    }
}
