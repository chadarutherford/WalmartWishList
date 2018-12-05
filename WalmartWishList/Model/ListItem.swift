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
    var items: [Items]
    
    struct Items: Codable {
        var name: String
        var salePrice: Double
        var thumbnailImage: String
        var availableOnline: Bool
    }
}


class ItemObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var salePrice = 0.0
    @objc dynamic var thumbnailImage = ""
    @objc dynamic var availableOnline = false
}


extension ListItem.Items: Persistable {
    public init(managedObject: ItemObject) {
        name = managedObject.name
        salePrice = managedObject.salePrice
        thumbnailImage = managedObject.thumbnailImage
        availableOnline = managedObject.availableOnline
    }
    
    public func managedObject() -> ItemObject {
        let item = ItemObject()
        
        item.name = name
        item.salePrice = salePrice
        item.thumbnailImage = thumbnailImage
        item.availableOnline = availableOnline
        
        return item
    }
}
