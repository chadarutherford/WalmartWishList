//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import Seam3

final class ListViewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var dataController: DataController!
    var list: List!
    var people = [Person]()
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        NotificationCenter.default.addObserver(forName: Notification.Name(SMStoreNotification.SyncDidFinish), object: nil, queue: nil) { [unowned self] notification in
            if notification.userInfo != nil {
                self.dataController.smStore?.triggerSync(complete: true)
            }
            self.dataController.viewContext.refreshAllObjects()
            DispatchQueue.main.async {
                self.loadData()
            }
        }
    }
    
    // MARK: - Helper Methods
    func loadData() {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            people = result
            tableView.reloadData()
        }
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            let personToDelete = self.person(at: indexPath)
            self.dataController.viewContext.delete(personToDelete)
            do {
                try self.dataController.viewContext.save()
            } catch {
                let alert = UIAlertController(title: "Error", message: "There was a problem deleting your record: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            self.people.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    func person(at indexPath: IndexPath) -> Person {
        return people[indexPath.row]
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
            addPersonVC.dataController = dataController
        case SegueConstant.itemsSegue:
            guard let listItemVC = segue.destination as? ListItemViewController else { return }
            if let indexPath = tableView.indexPathForSelectedRow {
                listItemVC.dataController = dataController
                listItemVC.person = person(at: indexPath)
            }
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
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.personCell, for: indexPath) as? PersonCell else { return UITableViewCell() }
        let person = people[indexPath.row]
        guard let name = person.name else { return UITableViewCell() }
        guard let count = person.items?.count else { return UITableViewCell() }
        guard let imageData = person.image else { return UITableViewCell() }
        cell.configure(withImage: imageData, withName: name, withItemCount: count)
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.itemsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
}
