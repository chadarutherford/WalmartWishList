//
//  List.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation

struct List: Codable {
    let title: String
    let items: [ItemObject]
    
    init(title: String, items: [ItemObject]) {
        self.title = title
        self.items = items
    }
}
