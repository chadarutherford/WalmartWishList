//
//  ListItem.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import RealmSwift

struct ListItem: Codable {
    var items: [Item]
    
    struct Item: Codable {
        var name: String
        var salePrice: Double
        var shortDescription: String
        var largeImage: String
        var availableOnline: Bool
    }
}
