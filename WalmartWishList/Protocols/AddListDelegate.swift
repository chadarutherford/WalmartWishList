//
//  AddListDelegate.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation

protocol AddListDelegate: AnyObject {
    func saveList(withTitle title: String)
}
