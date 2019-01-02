//
//  ItemObject.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

final class ItemObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var salePrice = 0.0
    @objc dynamic var shortDescription = ""
    @objc dynamic var thumbnailImage = Data()
    @objc dynamic var availableOnline = false
    @objc dynamic var isAvailable = "No"
    @objc dynamic var isPurchased = false
    var parentPerson = LinkingObjects(fromType: Person.self, property: "items")
    
    convenience required init(name: String, salePrice: Double, shortDescription: String, thumbnailImage: Data, availableOnline: Bool, isPurchased: Bool) {
        self.init()
        self.name = name
        self.salePrice = salePrice
        self.shortDescription = shortDescription
        self.thumbnailImage = thumbnailImage
        self.availableOnline = availableOnline
        self.isPurchased = isPurchased
    }
}
