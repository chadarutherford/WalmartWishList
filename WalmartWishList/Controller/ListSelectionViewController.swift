//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class ListSelectionViewController: UIViewController, AddListDelegate, PersistentContainerRequiring, CloudStoreRequiring {
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    var fetchedResultsController: NSFetchedResultsController<List>?
    var persistentContainer: NSPersistentContainer!
    var cloudStore: CloudStore!
    var listName: String?
    var shareList: CKRecord?
    var metaData: CKShare.Metadata?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let moc = persistentContainer.viewContext
        let request = NSFetchRequest<List>(entityName: "List")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let alert = UIAlertController(title: "Error", message: "The request to load existing records failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    // AddListDelegate Methods
    func saveList(withTitle title: String) {
        let moc = persistentContainer.viewContext
        moc.persist {
            let list = List(context: moc)
            list.title = title
            list.recordName = UUID().uuidString
            
            self.cloudStore.storeList(list) { _ in
                // no action
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // MARK: - Actions
    @IBAction func addTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueConstant.addList, sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.addList:
            guard let addListVC = segue.destination as? AddListViewController else { return }
            addListVC.delegate = self
        case SegueConstant.listSelected:
            guard let listViewVC = segue.destination as? ListViewViewController else { return }
            guard let selectedIndex = tableView.indexPathForSelectedRow else { return }
            guard let list = fetchedResultsController?.object(at: selectedIndex) else { return }
            listViewVC.persistentContainer = persistentContainer
            listViewVC.cloudStore = cloudStore
            listViewVC.metaData = metaData
            listViewVC.list = list
        default:
            break
        }
    }
}

extension ListSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.listCell, for: indexPath)
        guard let list = fetchedResultsController?.object(at: indexPath) else { return UITableViewCell() }
        cell.textLabel?.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.listSelected, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        persistentContainer.viewContext.persist { [weak self] in
            guard let objectToDelete = self?.fetchedResultsController?.object(at: indexPath) else { return }
            self?.persistentContainer.viewContext.delete(objectToDelete)
        }
    }
}

extension ListSelectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let insertIndex = newIndexPath else { return }
            tableView.insertRows(at: [insertIndex], with: .automatic)
        case .delete:
            guard let deleteIndex = indexPath else { return }
            tableView.deleteRows(at: [deleteIndex], with: .automatic)
        case .move:
            guard let fromIndex = indexPath, let toIndex = newIndexPath else { return }
            tableView.moveRow(at: fromIndex, to: toIndex)
        case .update:
            guard let updateIndex = indexPath else { return }
            tableView.reloadRows(at: [updateIndex], with: .automatic)
        @unknown default:
            break
        }
    }
}
