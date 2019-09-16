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
    var dataSource: ListDataSource!
    var dataProvider: DataProvider!
    var persistentContainer: NSPersistentContainer!
    var cloudStore: CloudStore!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        let moc = persistentContainer.viewContext
        self.dataProvider = DataProvider(managedObjectContext: moc)
        self.dataSource = ListDataSource(cellIdentifier: CellConstant.listCell, tableView: self.tableView, dataProvider: self.dataProvider)
        self.tableView.dataSource = self.dataSource
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
            let list = self.dataProvider.object(at: selectedIndex)
            listViewVC.persistentContainer = persistentContainer
            listViewVC.cloudStore = cloudStore
            listViewVC.list = list
        default:
            break
        }
    }
}

extension ListSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.listSelected, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
