//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

class ListSelectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var lists = [List]()
    var list: List?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        checkForChange()
    }
    
    // MARK: - Helper Methods
    func checkForChange() {
        DatabaseRefs.wishlists.addSnapshotListener { snapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            snapshot?.documentChanges.forEach { change in
                let data = change.document.data()
                var list: List
                do {
                    list = try FirestoreDecoder().decode(List.self, from: data)
                    list.documentID = change.document.documentID
                    let list = List(title: list.title, people: list.people, documentID: list.documentID)
                    guard let docData = try? FirestoreEncoder().encode(list) else { return }
                    DatabaseRefs.wishlists.document(list.documentID).updateData(docData)
                } catch let error {
                    debugPrint(error.localizedDescription)
                    return
                }
                switch change.type {
                case .added:
                    self.onListAdded(change: change, list: list)
                case .modified:
                    self.onListModified(change: change, list: list)
                case .removed:
                    self.onListRemoved(change: change)
                default:
                    break
                }
            }
        }
    }
    
    func onListAdded(change: DocumentChange, list: List) {
        let newIndex = Int(change.newIndex)
        lists.insert(list, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
    }
    
    func onListModified(change: DocumentChange, list: List) {
        if change.oldIndex == change.newIndex {
            let index = Int(change.oldIndex)
            lists[index] = list
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            lists.remove(at: Int(change.oldIndex))
            lists.insert(list, at: Int(change.newIndex))
            tableView.moveRow(at: IndexPath(row: Int(change.oldIndex), section: 0), to: IndexPath(row: Int(change.newIndex), section: 0))
            tableView.reloadRows(at: [IndexPath(row: Int(change.newIndex), section: 0), IndexPath(row: Int(change.oldIndex), section: 0)], with: .automatic)
        }
    }
    
    func onListRemoved(change: DocumentChange) {
        lists.remove(at: Int(change.oldIndex))
        tableView.deleteRows(at: [IndexPath(row: Int(change.oldIndex), section: 0)], with: .automatic)
    }
    
    // MARK: - Actions
    @IBAction func logoutTapped(_ sender: UIButton) {
        try? Auth.auth().signOut()
        let storyboard = UIStoryboard(name: Storyboard.main, bundle: nil)
        guard let loginVC = storyboard.instantiateViewController(withIdentifier: StoryboardIDs.login) as? LoginViewController else { return }
        present(loginVC, animated: true)
    }
    @IBAction func addTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add a list", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let text = alert.textFields?.first?.text else { return }
            self?.list = List(title: text, people: [], documentID: "")
            let docData = try? FirebaseEncoder().encode(self?.list)
            DatabaseRefs.wishlists.addDocument(data: docData as! [String : Any]) { error in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.listSelected:
            guard let listViewVC = segue.destination as? ListViewViewController else { return }
            listViewVC.list = list
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
        list = lists[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: SegueConstant.listSelected, sender: self)
    }
}
