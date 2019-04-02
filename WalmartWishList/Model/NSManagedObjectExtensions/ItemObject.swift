//
//  ItemObject.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension ItemObject {
    func recordIDForZone(_ zone: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.recordName!, zoneID: zone)
    }
    
    func recordForZone(_ zone: CKRecordZone.ID) -> CKRecord {
        let record: CKRecord
        
        if let data = cloudKitData, let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
            coder.requiresSecureCoding = true
            record = CKRecord(coder: coder)!
        } else {
            record = CKRecord(recordType: "ItemObject", recordID: recordIDForZone(zone))
        }
        
        record["name"] = name!
        record["salePrice"] = salePrice
        record["largeImage"] = largeImage
        record["shortDesc"] = shortDesc
        record["availableOnline"] = availableOnline
        record["isPurchased"] = isPurchased
        
        return record
    }
    
    static func find(byName name: String, orCreateIn moc: NSManagedObjectContext) -> ItemObject {
        let predicate = NSPredicate(format: "name == %@", name)
        let request: NSFetchRequest<ItemObject> = ItemObject.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return ItemObject(context: moc) }
        return result.first ?? ItemObject(context: moc)
    }
    
    static func find(byIdentifiers recordNames: [String], in moc: NSManagedObjectContext) -> [ItemObject] {
        let predicate = NSPredicate(format: "ANY recordName IN %@", recordNames)
        let request: NSFetchRequest<ItemObject> = ItemObject.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return [] }
        return result
    }
    
    static func find(byIdentifier recordName: String, in moc: NSManagedObjectContext) -> ItemObject? {
        let predicate = NSPredicate(format: "recordName == %@", recordName)
        let request: NSFetchRequest<ItemObject> = ItemObject.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return nil }
        return result.first
    }
}
