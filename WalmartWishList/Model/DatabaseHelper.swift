//
//  DatabaseHelper.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/26/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CloudKit

class DatabaseHelper {
    static let instance = DatabaseHelper()
    static let container = CKContainer.default()
    static let privateDatabase = container.privateCloudDatabase
    static let publicDatabase = container.publicCloudDatabase
    static let sharedDatabase = container.sharedCloudDatabase
}
