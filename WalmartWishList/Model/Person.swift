//
//  Person.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import RealmSwift

final class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var image = Data()
    @objc dynamic var itemCount = 0
    let items = List<ItemObject>()
    
    convenience required init(name: String, image: Data) {
        self.init()
        self.name = name
        self.image = image
    }
}
