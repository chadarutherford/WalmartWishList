//
//  User.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation

struct User: Codable {
    let firstName: String
    let lastName: String
    var name: String {
        return "\(firstName) \(lastName)"
    }
    let email: String
    let lists: [String]
    
    init(firstName: String, lastName: String, email: String, lists: [String]) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.lists = lists
    }
}
