//
//  SearchItemCell.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

final class SearchItemCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productAvailableLabel: UILabel!
    
    func configure(withImage imageData: Data, withName name: String, withPrice price: Double, withAvailability availability: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.productImageView.image = UIImage(data: imageData)
        }
        productNameLabel.text = name
        productPriceLabel.text = "Price: \(String(format: "$%.2f", price))"
        productAvailableLabel.text = "Available Online: \(availability ? "Yes" : "No")"
    }
}
