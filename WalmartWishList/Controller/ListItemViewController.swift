//
//  ListItemViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift

final class ListItemViewController: UIViewController, ItemDelegate {
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    // MARK: - Properties
    private let realm = try! Realm()
    private var items: [ItemObject]?
    var selectedPerson: Person? {
        didSet {
            loadItems()
            // loadItemsFromDelegate()
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
        do {
            try realm.write {
                guard let itemCount = items?.count else { return }
                selectedPerson?.itemCount = itemCount
            }
        } catch let error {
            print(error)
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            try realm.write {
                guard let itemCount = items?.count else { return }
                selectedPerson?.itemCount = itemCount
            }
        } catch let error {
            print(error)
        }
    }
    
//    // MARK: - Helper Methods
//    private func loadItemsFromDelegate() {
//        guard let name = delegate?.item?.name else { return }
//        guard let price = delegate?.item?.salePrice else { return }
//        guard let productDescription = delegate?.item?.shortDescription else { return }
//        guard let image = delegate?.item?.thumbnailImage else { return }
//        guard let available = delegate?.item?.availableOnline else { return }
//        item = ItemObject(name: name, salePrice: price, shortDescription: productDescription, thumbnailImage: image, availableOnline: available, isPurchased: false)
//        do {
//            try realm.write {
//                guard let item = item else { return }
//                realm.add(item)
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        } catch let error {
//            print(error)
//        }
//        tableView.reloadData()
//    }
    
    private func loadItems() {
        guard let realmItems = selectedPerson?.items else { return }
        items = Array(realmItems)
    }
    
    func contextualCompleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        guard let editItem = items?[indexPath.row] else { fatalError() }
        let action = UIContextualAction(style: .normal, title: "Purchased") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            do {
                try self?.realm.write {
                    editItem.isPurchased = !editItem.isPurchased
                }
            } catch let error {
                print(error)
            }
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.backgroundColor = UIColor.green
        return action
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        guard let deleteItem = items?[indexPath.row] else { fatalError() }
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            do {
                try self?.realm.write {
                    self?.realm.delete(deleteItem)
                }
            } catch let error {
                print(error)
            }
            self?.tableView.reloadData()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func unwindToListItemVC(segue: UIStoryboardSegue) {
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
            guard let image = UIImage(data: item.thumbnailImage) else { fatalError() }
            cell.configure(withImage: image, withName: item.name, withPrice: item.salePrice, withAvailability: item.availableOnline)
            print(item.isPurchased)
            cell.accessoryType = item.isPurchased ? .checkmark : .none
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = contextualCompleteAction(forRowAtIndexPath: indexPath)
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions:  [deleteAction, completeAction])
        return swipeConfig
    }
}
