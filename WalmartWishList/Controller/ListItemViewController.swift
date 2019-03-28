//
//  ListItemViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import Seam3

final class ListItemViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    // MARK: - Properties
    var dataController: DataController!
    var person: Person!
    var items = [ItemObject]()
    
    
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let person = person {
            pageTitleLabel.text = person.name
        }
        loadData()
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue:SMStoreNotification.SyncDidFinish), object: nil, queue: nil) { [unowned self] notification in
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
    private func loadData() {
        let fetchRequest = NSFetchRequest<ItemObject>(entityName: "ItemObject")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            items = result
            tableView.reloadData()
        }
    }
    
    private func item(at indexPath: IndexPath) -> ItemObject {
        return items[indexPath.row]
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            let itemToDelete = self.item(at: indexPath)
            self.dataController.viewContext.delete(itemToDelete)
            do {
                try self.dataController.viewContext.save()
            } catch {
                let alert = UIAlertController(title: "Error", message: "There was a problem deleting your record: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    private func contextualCompleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Purchased") { [unowned self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            let itemToCheck = self.item(at: indexPath)
            itemToCheck.isPurchased = !itemToCheck.isPurchased
            do {
                try self.dataController.viewContext.save()
            } catch {
                let alert = UIAlertController(title: "Error", message: "There was a problem changing your record: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
            productSearchVC.dataController = dataController
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
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.itemsCell, for: indexPath) as? ItemsCell else { return UITableViewCell() }
        let item = items[indexPath.row]
        guard let name = item.name else { return UITableViewCell() }
        guard let imageData = item.largeImage else { return UITableViewCell() }
        cell.configure(withImage: imageData, withName: name, withPrice: item.salePrice, withAvailability: item.availableOnline)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = contextualCompleteAction(forRowAtIndexPath: indexPath)
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return swipeConfig
    }
}

