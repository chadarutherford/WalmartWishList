//
//  ItemObject.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import RealmSwift

class ItemObject: Object {
    @objc dynamic var name = ""
    @objc dynamic var salePrice = 0.0
    @objc dynamic var shortDescription = ""
    @objc dynamic var thumbnailImage = Data()
    @objc dynamic var availableOnline = false
    @objc dynamic var isAvailable = "No"
    var parentPerson = LinkingObjects(fromType: Person.self, property: "items")
}
