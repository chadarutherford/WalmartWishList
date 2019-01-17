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
    
    private func saveItemsFromDelegate() {
        guard let name = delegate?.item?.name else { return }
        guard let price = delegate?.item?.salePrice else { return }
        guard let productDescription = delegate?.item?.shortDescription else { return }
        guard let image = delegate?.item?.largeImage else { return }
        guard let available = delegate?.item?.availableOnline else { return }
        item = ItemObject(name: name, salePrice: price, shortDescription: productDescription, largeImage: image, availableOnline: available)
        tableView.reloadData()
    }
    
    func loadItems() {
        items = selectedPerson?.items
    }
    
    // MARK: - Actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func unwindToListItemVC(_ segue: UIStoryboardSegue) {
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
        }
        return cell
    }
}

