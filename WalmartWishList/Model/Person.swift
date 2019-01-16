//
//  Person.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation

struct Person: Codable {
    var name: String
    var image: String
    var itemCount: Int
    var items: [ItemObject]
    
    init(name: String, image: String, itemCount: Int, items: [ItemObject]) {
        self.name = name
        self.image = image
        self.itemCount = itemCount
        self.items = items
    }
}
