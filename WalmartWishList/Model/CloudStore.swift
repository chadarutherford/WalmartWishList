//
//  CloudStore.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class CloudStore {
    let persistentContainer: NSPersistentContainer
    
    var isSubscribedToDatabase: Bool {
        get { return UserDefaults.standard.bool(forKey: "CloudStore.isSubscribedToDatabase") }
        set { UserDefaults.standard.set(newValue, forKey: "CloudStore.isSubscribedToDatabase") }
    }
    
    var isSubscribedToSharedDatabase: Bool {
        get { return UserDefaults.standard.bool(forKey: "CloudStore.isSubscribedToSharedDatabase") }
        set { UserDefaults.standard.set(newValue, forKey: "CloudStore.isSubscribedToSharedDatabase") }
    }
    
    var privateDatabaseChangeToken: CKServerChangeToken? {
        get { return UserDefaults.standard.serverChangeToken(forKey: "CloudStore.privateDatabaseChangeToken") }
        set { UserDefaults.standard.set(newValue, forKey: "CloudStore.privateDatabaseChangeToken") }
    }
    
    var privateDatabase: CKDatabase {
        return CKContainer.default().privateCloudDatabase
    }
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
}

extension CloudStore {
    func subscribeToChangesIfNeeded(_ completion: @escaping (Error?) -> ()) {
        guard isSubscribedToDatabase == false else {
            completion(nil)
            return
        }
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        let subscription = CKDatabaseSubscription(subscriptionID: "private-changes")
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        
        operation.modifySubscriptionsCompletionBlock = { [unowned self] subscriptions, subscriptionIDs, error in
            if error == nil {
                self.isSubscribedToDatabase = true
            }
            completion(error)
        }
        privateDatabase.add(operation)
    }
    
    func subscribeToSharedDatabase(_ completion: @escaping (Error?) -> ()) {
        guard isSubscribedToSharedDatabase == false else {
            completion(nil)
            return
        }
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        let subscription = CKDatabaseSubscription(subscriptionID: "shared-changes")
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        
        operation.modifySubscriptionsCompletionBlock = { [unowned self] subscriptions, subscriptionIds, error in
            if error == nil {
                self.isSubscribedToSharedDatabase = true
            }
            completion(error)
        }
        CKContainer.default().sharedCloudDatabase.add(operation)
    }
}

extension CloudStore {
    func handleNotification(_ dict: [String : AnyObject], completionHandler: @escaping (UIBackgroundFetchResult) -> ()) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: dict) else { return }
        
        if notification.subscriptionID == "private-changes" {
            fetchDatabaseChanges { error in
                if error == nil {
                    completionHandler(.newData)
                } else {
                    completionHandler(.failed)
                }
            }
        } else if notification.subscriptionID == "shared-changes" {
            
        }
    }
}

extension CloudStore {
    func fetchDatabaseChanges(_ completionHandler: @escaping (Error?) -> ()) {
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: privateDatabaseChangeToken)
        
        var zoneIds = [CKRecordZone.ID]()
        operation.recordZoneWithIDChangedBlock = { zoneId in
            zoneIds.append(zoneId)
        }
        
        operation.changeTokenUpdatedBlock = { [weak self] changeToken in
            self?.privateDatabaseChangeToken = changeToken
        }
        
        operation.fetchDatabaseChangesCompletionBlock = { [weak self] changeToken, success, error in
            self?.privateDatabaseChangeToken = changeToken
            
            if zoneIds.count > 0 && error == nil {
                self?.fetchZoneChangesInZones(zoneIds, completionHandler)
            } else {
                completionHandler(error)
            }
        }
        privateDatabase.add(operation)
    }
}

extension CloudStore {
    func fetchZoneChangesInZones(_ zones: [CKRecordZone.ID], _ completionHandler: @escaping (Error?) -> ()) {
        var fetchConfigurations = [CKRecordZone.ID : CKFetchRecordZoneChangesOperation.ZoneConfiguration]()
        for zone in zones {
            if let changeToken = UserDefaults.standard.zoneChangeToken(forZone: zone) {
                let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: changeToken, resultsLimit: nil, desiredKeys: nil)
                fetchConfigurations[zone] = configuration
            }
        }
        
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zones, configurationsByRecordZoneID: fetchConfigurations)
        let backgroundContext = persistentContainer.newBackgroundContext()
        var changedLists = [CKRecord]()
        var changedPeople = [CKRecord]()
        var changedItems = [CKRecord]()
        
        operation.recordChangedBlock = { record in
            if record.recordType == "ItemObject" {
                changedItems.append(record)
            } else if record.recordType == "Person" {
                changedPeople.append(record)
            } else if record.recordType == "List" {
                changedLists.append(record)
            }
        }
        
        operation.fetchRecordZoneChangesCompletionBlock = { [weak self] error in
            for record in changedItems {
                self?.importItem(withRecord: record, withContext: backgroundContext)
            }
            
            for record in changedPeople {
                self?.importPerson(withRecord: record, withContext: backgroundContext)
            }
            
            for record in changedLists {
                self?.importList(withRecord: record, withContext: backgroundContext)
            }
            
            completionHandler(error)
        }
        
        operation.recordZoneFetchCompletionBlock = { recordZone, changeToken, data, moreComing, error in
            UserDefaults.standard.set(changeToken, forZone: recordZone)
        }
        privateDatabase.add(operation)
    }
}

extension CloudStore {
    func importItem(withRecord record: CKRecord, withContext moc: NSManagedObjectContext) {
        moc.persist {
            let identifier = record.recordID.recordName
            let item = ItemObject.find(byIdentifier: identifier, in: moc) ?? ItemObject(context: moc)
            item.name = record["name"] ?? "unknown-name"
            item.largeImage = record["largeImage"] ?? Data()
            item.salePrice = record["salePrice"] ?? 0.0
            item.shortDesc = record["shortDesc"] ?? ""
            item.availableOnline = record["availableOnline"] ?? false
            item.isPurchased = record["isPurchased"] ?? false
            item.cloudKitData = record.encodedSystemFields
            item.recordName = identifier
        }
    }
    
    func importPerson(withRecord record: CKRecord, withContext moc: NSManagedObjectContext) {
        moc.persist {
            let identifier = record.recordID.recordName
            let person = Person.find(byIdentifier: identifier, in: moc) ?? Person(context: moc)
            person.name = record["name"] ?? "unknown-name"
            person.image = record["image"] ?? Data()
            person.itemCount = record["itemCount"] ?? Int64(0)
            person.cloudKitData = record.encodedSystemFields
            person.recordName = identifier
            
            if let itemReferences = record["items"] as? [CKRecord.Reference] {
                let itemIds = itemReferences.map { reference in
                    return reference.recordID.recordName
                }
                
                person.items = NSSet(array: ItemObject.find(byIdentifiers: itemIds, in: moc))
            }
        }
    }
    
    func importList(withRecord record: CKRecord, withContext moc: NSManagedObjectContext) {
        moc.persist {
            let identifier = record.recordID.recordName
            let list = List.find(byIdentifier: identifier, in: moc) ?? List(context: moc)
            list.title = record["title"] ?? "unknown-title"
            list.cloudKitData = record.encodedSystemFields
            list.recordName = identifier
            
            if let personReferences = record["people"] as? [CKRecord.Reference] {
                let personIds = personReferences.map { reference in
                    return reference.recordID.recordName
                }
                
                list.people = NSSet(array: Person.find(byIdentifiers: personIds, in: moc))
            }
        }
    }
}

extension CloudStore {
    func storeList(_ list: List, _ completionHandler: @escaping (Error?) -> ()) {
        guard let people = list.people as? Set<Person> else {
            completionHandler(nil)
            return
        }
        
        let defaultZoneId = CKRecordZone.ID(zoneName: "listsZone", ownerName: CKCurrentUserDefaultName)
        
        var recordsToSave = people.map { person in
            person.recordForZone(defaultZoneId)
        }
        recordsToSave.append(list.recordForZone(defaultZoneId))
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { records, recordIds, error in
            guard let records = records, error == nil else {
                completionHandler(error)
                return
            }
            
            for record in records {
                if record.recordType == "List" {
                    list.managedObjectContext?.persist {
                        list.cloudKitData = record.encodedSystemFields
                    }
                } else if record.recordType == "Person", let person = people.first(where: { $0.recordName == record.recordID.recordName }) {
                    list.managedObjectContext?.persist {
                        person.cloudKitData = record.encodedSystemFields
                    }
                }
            }
            completionHandler(error)
        }
        privateDatabase.add(operation)
    }
    
    func storePerson(_ person: Person, _ completionHandler: @escaping (Error?) -> ()) {
        guard let items = person.items as? Set<ItemObject> else {
            completionHandler(nil)
            return
        }
        
        let defaultZoneId = CKRecordZone.ID(zoneName: "listsZone", ownerName: CKCurrentUserDefaultName)
        
        var recordsToSave = items.map { item in
            item.recordForZone(defaultZoneId)
        }
        recordsToSave.append(person.recordForZone(defaultZoneId))
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { records, recordIds, error in
            guard let records = records, error == nil else {
                completionHandler(error)
                return
            }
            
            for record in records {
                if record.recordType == "Person" {
                    person.managedObjectContext?.persist {
                        person.cloudKitData = record.encodedSystemFields
                    }
                } else if record.recordType == "ItemObject", let item = items.first(where: {$0.recordName == record.recordID.recordName }) {
                    person.managedObjectContext?.persist {
                        item.cloudKitData = record.encodedSystemFields
                    }
                }
            }
            completionHandler(error)
        }
        privateDatabase.add(operation)
    }
}
