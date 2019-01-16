//
//  RoundedButton.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/16/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = layer.bounds.height / 2
        layer.masksToBounds = true
    }
}
