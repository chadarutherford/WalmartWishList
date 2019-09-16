//
//  DataProvider.swift
//  CloudWishList
//
//  Created by Chad Rutherford on 5/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation
import CoreData

class DataProvider: NSObject, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext!
    private var fetchedResultsController: NSFetchedResultsController<List>!
    weak var delegate: DataProviderDelegate!
    
    init(managedObjectContext: NSManagedObjectContext) {
        super.init()
        self.managedObjectContext = managedObjectContext
        let request = NSFetchRequest<List>(entityName: "List")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController?.performFetch()
        } catch let error {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func object(at indexPath: IndexPath) -> List {
        return self.fetchedResultsController.object(at: indexPath)
    }
    
    func numberOfSections() -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func delete(list: List) {
        managedObjectContext.persist { [unowned self] in
            self.managedObjectContext.delete(list)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            self.delegate.dataProviderDidInsert(indexPath: newIndexPath)
        case .delete:
            guard let indexPath = indexPath else { return }
            self.delegate.dataProviderDidDelete(indexPath: indexPath)
        case .move:
            guard let fromIndex = indexPath, let toIndex = newIndexPath else { return }
            self.delegate.dataProviderDidMove(at: fromIndex, to: toIndex)
        case .update:
            guard let updateIndex = indexPath else { return }
            self.delegate.dataProviderDidUpdate(indexPath: updateIndex)
        @unknown default:
            break
        }
    }
}
