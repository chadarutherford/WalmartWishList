//
//  DataController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/28/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
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
