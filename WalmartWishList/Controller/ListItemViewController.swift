//
//  ListItemViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

final class ListItemViewController: UIViewController, PersistentContainerRequiring, CloudStoreRequiring {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    // MARK: - Properties
    var person: Person!
    var fetchedResultsController: NSFetchedResultsController<ItemObject>?
    var persistentContainer: NSPersistentContainer!
    var cloudStore: CloudStore!
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let moc = persistentContainer.viewContext
        let request = NSFetchRequest<ItemObject>(entityName: "ItemObject")
        let predicate = NSPredicate(format: "person == %@", person)
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let alert = UIAlertController(title: "Error", message: "The request to load existing records failed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        if let person = person {
            pageTitleLabel.text = person.name
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        persistentContainer.viewContext.persist { [weak self] in
            guard let items = self?.fetchedResultsController?.fetchedObjects?.count else { return }
            self?.person?.itemCount = Int64(items)
        }
    }
    
    // MARK: - Helper Methods
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            self?.persistentContainer.viewContext.persist {
                guard let itemToDelete = self?.fetchedResultsController?.object(at: indexPath) else { return }
                self?.persistentContainer.viewContext.delete(itemToDelete)
                self?.person.itemCount -= 1
            }
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    private func contextualCompleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Purchased") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            self?.persistentContainer.viewContext.persist {
                guard let itemToCheck = self?.fetchedResultsController?.object(at: indexPath) else { return }
                itemToCheck.isPurchased = !itemToCheck.isPurchased
            }
            completionHandler(true)
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    // MARK: - Actions
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func addTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueConstant.searchSegue, sender: self)
    }
    
    @IBAction private func unwindToListItemVC(_ segue: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.searchSegue:
            guard let productSearchVC = segue.destination as? ProductSearchViewController else { return }
            productSearchVC.persistentContainer = persistentContainer
            productSearchVC.person = person
            productSearchVC.cloudStore = cloudStore
        default:
            break
        }
    }
}

// MARK: - TableView Extension
extension ListItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.itemsCell, for: indexPath) as? ItemsCell else { return UITableViewCell() }
        guard let item = fetchedResultsController?.object(at: indexPath) else { return UITableViewCell() }
        guard let imageData = item.largeImage else { return UITableViewCell() }
        guard let name = item.name else { return UITableViewCell() }
        cell.configure(withImage: imageData, withName: name, withPrice: item.salePrice, withAvailability: item.availableOnline)
        cell.accessoryType = item.isPurchased ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = contextualCompleteAction(forRowAtIndexPath: indexPath)
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return swipeConfig
    }
}

extension ListItemViewController: NSFetchedResultsControllerDelegate {
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
