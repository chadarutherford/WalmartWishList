//
//  ListViewViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

final class ListViewViewController: UIViewController, PersistentContainerRequiring, CloudStoreRequiring {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var persistentContainer: NSPersistentContainer!
    var cloudStore: CloudStore!
    var fetchedResultsController: NSFetchedResultsController<Person>?
    var list: List!
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let moc = persistentContainer.viewContext
        let request = NSFetchRequest<Person>(entityName: "Person")
        let predicate = NSPredicate(format: "list == %@", list)
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
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueConstant.addPersonSegue, sender: self)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.addPersonSegue:
            guard let addPersonVC = segue.destination as? AddPersonViewController else { return }
            addPersonVC.persistentContainer = persistentContainer
            addPersonVC.list = list
            addPersonVC.cloudStore = cloudStore
        case SegueConstant.itemsSegue:
            guard let listItemVC = segue.destination as? ListItemViewController else { return }
            listItemVC.persistentContainer = persistentContainer
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            listItemVC.person = fetchedResultsController?.object(at: indexPath)
            listItemVC.cloudStore = cloudStore
        default:
            break
        }
    }
}

// MARK: - TableViewExtension
extension ListViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.personCell, for: indexPath) as? PersonCell else { return UITableViewCell() }
        guard let person = fetchedResultsController?.object(at: indexPath) else { return UITableViewCell() }
        guard let imageData = person.image else { return UITableViewCell() }
        guard let name = person.name else { return UITableViewCell() }
        cell.configure(withImage: imageData, withName: name, withItemCount: Int(person.itemCount))
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.itemsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        persistentContainer.viewContext.persist { [weak self] in
            guard let personToDelete = self?.fetchedResultsController?.object(at: indexPath) else { return }
            self?.persistentContainer.viewContext.delete(personToDelete)
        }
    }
}

extension ListViewViewController: NSFetchedResultsControllerDelegate {
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
