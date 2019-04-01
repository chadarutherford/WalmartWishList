//
//  PersistentContainerRequiring.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import CoreData

protocol PersistentContainerRequiring {
    var persistentContainer: NSPersistentContainer! { get set }
}
