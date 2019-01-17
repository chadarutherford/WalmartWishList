//
//  ItemObject.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation

final class ItemObject: Codable {
    var name: String
    var salePrice: Double
    var shortDescription: String
    var largeImage: String
    var availableOnline: Bool
    var isPurchased: Bool
    
    init(name: String, salePrice: Double, shortDescription: String, largeImage: String, availableOnline: Bool, isPurchased: Bool) {
        self.name = name
        self.salePrice = salePrice
        self.shortDescription = shortDescription
        self.largeImage = largeImage
        self.availableOnline = availableOnline
        self.isPurchased = isPurchased
    }
}
