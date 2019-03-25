//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import Firebase
import CodableFirebase

final class ListViewViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var list: List?
    var person: Person?
    var index = 0
    
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        checkForChange()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func checkForChange() {
        DatabaseRefs.wishlists.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            snapshot?.documentChanges.forEach { change in
                let data = change.document.data()
                do {
                    let newList = try FirestoreDecoder().decode(List.self, from: data)
                    self?.list = newList
                    self?.tableView.reloadData()
                } catch let error {
                    debugPrint(error.localizedDescription)
                    return
                }
            }
        }
    }
    
    private func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> ()) in
            guard let documentID = self?.list?.documentID else { return }
            DatabaseRefs.wishlists.document(documentID).delete()
            completionHandler(true)
        }
        action.backgroundColor = UIColor.red
        return action
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
        case SegueConstant.itemsSegue:
            guard let listItemViewController = segue.destination as? ListItemViewController else { return }
            guard let list = list else { return }
            guard let person = person else { return }
            listItemViewController.selectedPerson = person
            listItemViewController.list = list
            listItemViewController.index = index
        case SegueConstant.addPersonSegue:
            guard let addPersonViewController = segue.destination as? AddPersonViewController else { return }
            addPersonViewController.list = list
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
        guard let list = list else { return 0 }
        return list.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.personCell, for: indexPath) as? PersonCell else { return UITableViewCell() }
        guard let person = list?.people[indexPath.row] else { return UITableViewCell() }
        cell.configure(withImage: person.image, withName: person.name, withItemCount: person.itemCount)
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let list = list else { return }
        person = list.people[indexPath.row]
        index = indexPath.row
        performSegue(withIdentifier: SegueConstant.itemsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
}
