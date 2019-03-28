//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import Seam3

class ListSelectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var lists = [List]()
    var dataController: DataController!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: SMStoreNotification.SyncDidFinish), object: nil, queue: nil) { notification in
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
        let fetchRequest = NSFetchRequest<List>(entityName: "List")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            lists = result
            tableView.reloadData()
        }
    }
    
    func list(at indexPath: IndexPath) -> List {
        return lists[indexPath.row]
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
            addListVC.dataController = dataController
        case SegueConstant.listSelected:
            guard let listViewVC = segue.destination as? ListViewViewController else { return }
            if let indexPath = tableView.indexPathForSelectedRow {
                listViewVC.dataController = dataController
                listViewVC.list = list(at: indexPath)
            }
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
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.listCell, for: indexPath)
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.listSelected, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let listToDelete = list(at: indexPath)
        dataController.viewContext.delete(listToDelete)
        do {
            try dataController.viewContext.save()
        } catch {
            let alert = UIAlertController(title: "Error", message: "There was a problem deleting your record: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        self.lists.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

