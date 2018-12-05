//
//  Person.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import RealmSwift

class Person: Object {
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    @objc dynamic var itemCount = 0
}
