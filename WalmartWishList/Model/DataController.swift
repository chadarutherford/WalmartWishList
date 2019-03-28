//
//  DataController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/28/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData
import Seam3

class DataController {
    var smStore: SMStore?
    
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        SMStore.registerStoreClass()
        let container = NSPersistentContainer(name: "WishListModel")
        if let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let url = applicationDocumentsDirectory.appendingPathComponent("CoreData.sqlite")
            let storeDescription = NSPersistentStoreDescription(url: url)
            storeDescription.type = SMStore.type
            container.persistentStoreDescriptions = [storeDescription]
            container.loadPersistentStores { storeDescription, error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
            return container
        }
        fatalError("Unable to access documents directory.")
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    func validateCloudKitAndSync(_ completion:@escaping (() -> Void)) {
        
        self.smStore?.verifyCloudKitConnectionAndUser() { (status, user, error) in
            guard status == .available, error == nil else {
                NSLog("Unable to verify CloudKit Connection \(error!)")
                return
            }
            
            guard let currentUser = user else {
                NSLog("No current CloudKit user")
                return
            }
            
            if let previousUser = UserDefaults.standard.string(forKey: "CloudKitUser") {
                if  previousUser != currentUser  {
                    do {
                        print("New user")
                        try self.smStore?.resetBackingStore()
                    } catch {
                        NSLog("Error resetting backing store - \(error.localizedDescription)")
                        return
                    }
                }
            }
            
            UserDefaults.standard.set(currentUser, forKey:"CloudKitUser")
            
            self.smStore?.triggerSync(complete: true)
            
            completion()
        }
        
    }
}

public extension NSManagedObject {
    convenience init(context: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}


extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            print("Cannot set negative autosave interval.")
            return
        }
        if viewContext.hasChanges {
            viewContext.perform { [weak self] in
                try? self?.viewContext.save()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
