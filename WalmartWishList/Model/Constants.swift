//
//  Constants.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation
import Firebase

struct CellConstant {
    static let personCell = "PersonCell"
    static let searchItemCell = "SearchItemCell"
    static let itemsCell = "ItemsCell"
    static let listCell = "ListCell"
}

struct Storyboard {
    static let listSelection = "ListSelection"
    static let main = "Main"
}

struct StoryboardIDs {
    static let login = "LoginVC"
    static let listSelection = "ListSelectionVC"
}

struct SegueConstant {
    static let addPersonSegue = "addPerson"
    static let itemsSegue = "goToItems"
    static let searchSegue = "goToSearch"
    static let detailSegue = "goToDetail"
    static let unwindToListItem = "unwindToListItemVC"
    static let loggedIn = "LoggedIn"
    static let signedUp = "SignedUp"
    static let listSelected = "listSelected"
    static let logout = "logout"
}

struct NetworkingConstants {
    static let baseURL = "https://api.walmartlabs.com/v1/search?"
    static let apiKey = "apiKey=5cjczkw7a8ghwxduvgwrhk4v"
    static let finalUrl = "&query="
}

struct DatabaseRefs {
    static let wishlists = Firestore.firestore().collection("WishLists")
    static let photos = Storage.storage().reference()
}
