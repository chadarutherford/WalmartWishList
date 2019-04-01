//
//  ItemObject.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData

extension ItemObject {
    static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> ItemObject {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<ItemObject> = ItemObject.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return ItemObject(context: moc) }
        return result.first ?? ItemObject(context: moc)
    }
}
