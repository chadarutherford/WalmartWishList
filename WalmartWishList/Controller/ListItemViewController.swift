//
//  ListItemViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/5/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift

class ListItemViewController: UIViewController, ItemDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    // MARK: - Properties
    let realm = try! Realm()
    var items: Results<ItemObject>?
    var selectedPerson: Person? {
        didSet {
            loadItems()
            loadItemsFromDelegate()
        }
    }
    var delegate: ItemDelegate?
    
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
    
    func loadItemsFromDelegate() {
        guard let name = delegate?.item.name else { return }
        guard let price = delegate?.item.salePrice else { return }
        guard let productDescription = delegate?.item.shortDescription else { return }
        guard let available = delegate?.item.availableOnline else { return }
        
        item.name = name
        item.salePrice = price
        item.shortDescription = productDescription
        item.availableOnline = available
        do {
            try realm.write {
                realm.add(item)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch let error {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        items = selectedPerson?.items.sorted(byKeyPath: "name", ascending: true)
    }
    
    // MARK: - Item Delegate
    var item = ItemObject()
    
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
            cell.itemNameLabel.text = item.name
            cell.itemPriceLabel.text = String(format: "$%.2f", item.salePrice)
            cell.itemAvailableLabel.text = "Available Online: \(item.availableOnline ? "Yes" : "No")"
        } else {
            cell.itemNameLabel.text = "Tap add button to add items to list"
        }
        return cell
    }
}
