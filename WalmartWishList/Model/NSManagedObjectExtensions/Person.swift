//
//  Person.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Person {
    func recordIDForZone(_ zone: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.recordName!, zoneID: zone)
    }
    
    func recordForZone(_ zone: CKRecordZone.ID) -> CKRecord {
        let record: CKRecord
        
        if let data = cloudKitData, let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
            coder.requiresSecureCoding = true
            record = CKRecord(coder: coder)!
        } else {
            record = CKRecord(recordType: "Person", recordID: recordIDForZone(zone))
        }
        
        record["name"] = name!
        record["image"] = image
        record["itemCount"] = itemCount
        
        if let items = self.items as? Set<ItemObject> {
            let references: [CKRecord.Reference] = items.map { item in
                let itemRecord = item.recordForZone(zone)
                return CKRecord.Reference(record: itemRecord, action: .deleteSelf)
            }
            record["items"] = references
        }
        
        return record
    }
    
    static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> Person {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return Person(context: moc) }
        return result.first ?? Person(context: moc)
    }
    
    static func find(byIdentifiers recordNames: [String], in moc: NSManagedObjectContext) -> [Person] {
        let predicate = NSPredicate(format: "ANY recordName IN %@", recordNames)
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return [] }
        return result
    }
    
    static func find(byIdentifier recordName: String, in moc: NSManagedObjectContext) -> Person? {
        let predicate = NSPredicate(format: "recordName == %@", recordName)
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return nil }
        return result.first
    }
}
