//
//  SearchItem.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/29/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation

class SearchItem {
    var name: String
    var salePrice: Double
    var largeImage: Data
    var shortDesc: String
    var availableOnline: Bool
    var isPurchased: Bool
    
    init(name: String, salePrice: Double, largeImage: Data, shortDesc: String, availableOnline: Bool, isPurchased: Bool) {
        self.name = name
        self.salePrice = salePrice
        self.largeImage = largeImage
        self.shortDesc = shortDesc
        self.availableOnline = availableOnline
        self.isPurchased = isPurchased
    }
}
