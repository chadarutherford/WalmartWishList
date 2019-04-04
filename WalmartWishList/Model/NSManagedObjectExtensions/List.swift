//
//  List.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension List {
    func recordIDForZone(_ zone: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.recordName!, zoneID: zone)
    }
    
    func recordForZone(_ zone: CKRecordZone.ID) -> CKRecord {
        let record: CKRecord
        
        if let data = cloudKitData, let coder = try? NSKeyedUnarchiver(forReadingFrom: data) {
            coder.requiresSecureCoding = true
            record = CKRecord(coder: coder)!
        } else {
            record = CKRecord(recordType: "List", recordID: recordIDForZone(zone))
        }
        
        record["title"] = title!
        
        if let people = self.people as? Set<Person> {
            let references: [CKRecord.Reference] = people.map { person in
                let personRecord = person.recordForZone(zone)
                return CKRecord.Reference(record: personRecord, action: .deleteSelf)
            }
            record["people"] = references
        }
        
        return record
    }
    
    static func find(byIdentifier recordName: String, in moc: NSManagedObjectContext) -> List? {
        let predicate = NSPredicate(format: "recordName == %@", recordName)
        let request: NSFetchRequest<List> = List.fetchRequest()
        request.predicate = predicate
        
        guard let result = try? moc.fetch(request) else { return nil }
        return result.first
    }
}
