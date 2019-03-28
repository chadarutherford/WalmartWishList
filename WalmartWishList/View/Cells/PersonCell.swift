//
//  PersonCell.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit

final class PersonCell: UITableViewCell {
    
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    
    func configure(withImage imageData: Data, withName name: String, withItemCount itemCount: Int) {
        personImageView.image = UIImage(data: imageData)
        nameLabel.text = name
        itemCountLabel.text = "Items: \(itemCount)"
    }
}
