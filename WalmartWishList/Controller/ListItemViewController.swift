//
//  ListItemViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

final class ListItemViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    // MARK: - Properties
    private var items: [ItemObject]?
    var selectedPerson: Person? {
        didSet {
            saveItemsFromDelegate()
            loadItems()
            guard let items = items else { return }
            selectedPerson?.itemCount = items.count
        }
    }
    var delegate: ItemDelegate?
    
    // MARK: - Item Delegate
    var item: ItemObject?
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let name = selectedPerson?.name else { return }
        pageTitleLabel.text = name
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let person = selectedPerson else { return }
        let documentID = person.documentID
        guard let docData = try? FirestoreEncoder().encode(selectedPerson) else { return }
        Firestore.firestore().collection("List").document(documentID).updateData(docData)
    }
    
    // MARK: - Helper Methods
    private func saveItemsFromDelegate() {
        guard let name = delegate?.item?.name else { return }
        guard let price = delegate?.item?.salePrice else { return }
        guard let productDescription = delegate?.item?.shortDescription else { return }
        guard let image = delegate?.item?.largeImage else { return }
        guard let available = delegate?.item?.availableOnline else { return }
        item = ItemObject(name: name, salePrice: price, shortDescription: productDescription, largeImage: image, availableOnline: available, isPurchased: false)
        tableView.reloadData()
    }
    
    private func loadItems() {
        items = selectedPerson?.items
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            guard let person = self?.selectedPerson else { return }
            let documentID = person.documentID
            var deletedItemPerson = person
            deletedItemPerson.items.remove(at: indexPath.row)
            self?.items?.remove(at: indexPath.row)
            deletedItemPerson.itemCount = deletedItemPerson.items.count
            guard let docData = try? FirestoreEncoder().encode(deletedItemPerson) else { return }
            Firestore.firestore().collection("List").document(documentID).updateData(docData)
            self?.tableView.reloadData()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    private func contextualCompleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Purchased") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            guard let person = self?.selectedPerson else { return }
            let documentID = person.documentID
            person.items[indexPath.row].isPurchased = !person.items[indexPath.row].isPurchased
            guard let docData = try? FirestoreEncoder().encode(self?.selectedPerson) else { return }
            Firestore.firestore().collection("List").document(documentID).updateData(docData)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    // MARK: - Actions
    @IBAction private func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func unwindToListItemVC(_ segue: UIStoryboardSegue) {
    }
}

// MARK: - TableView Extension
extension ListItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.itemsCell, for: indexPath) as? ItemsCell else { return UITableViewCell() }
        if let item = items?[indexPath.row] {
            guard let imageURL = URL(string: item.largeImage) else { return UITableViewCell() }
            guard let imageData = try? Data(contentsOf: imageURL) else { return UITableViewCell() }
            guard let image = UIImage(data: imageData) else { return UITableViewCell() }
            cell.configure(withImage: image, withName: item.name, withPrice: item.salePrice, withAvailability: item.availableOnline)
            cell.accessoryType = item.isPurchased ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = contextualCompleteAction(forRowAtIndexPath: indexPath)
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return swipeConfig
    }
}

