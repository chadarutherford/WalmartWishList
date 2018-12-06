//
//  Constants.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation

struct CellConstant {
    static let personCell = "PersonCell"
    static let searchItemCell = "SearchItemCell"
    static let itemsCell = "ItemsCell"
}

struct SegueConstant {
    static let addPersonSegue = "addPerson"
    static let itemsSegue = "goToItems"
    static let searchSegue = "goToSearch"
    static let detailSegue = "goToDetail"
}

struct NetworkingConstants {
    static let baseURL = "https://api.walmartlabs.com/v1/search?"
    static let apiKey = "apiKey=5cjczkw7a8ghwxduvgwrhk4v"
    static let finalUrl = "&query="
}
