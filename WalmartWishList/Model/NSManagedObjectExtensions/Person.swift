//
//  Person.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData

extension Person {
    static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> Person {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return Person(context: moc) }
        return result.first ?? Person(context: moc)
    }
}
