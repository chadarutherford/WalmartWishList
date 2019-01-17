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

final class ListSelectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var person: Person?
    private var people = [Person]()
    
    
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
    
    // MARK: - Helper Methods
    private func checkForChange() {
        Firestore.firestore().collection("List").addSnapshotListener { snapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            snapshot?.documentChanges.forEach({ change in
                let data = change.document.data()
                var person: Person
                do {
                    person = try FirestoreDecoder().decode(Person.self, from: data)
                    person.documentID = change.document.documentID
                } catch let error {
                    debugPrint(error.localizedDescription)
                    return
                }
                switch change.type {
                case .added:
                    self.onPersonAdded(change: change, person: person)
                case .modified:
                    self.onPersonModified(change: change, person: person)
                case .removed:
                    self.onPersonRemoved(change: change)
                }
            })
        }
    }
    
    private func onPersonAdded(change: DocumentChange, person: Person) {
        let newIndex = Int(change.newIndex)
        people.insert(person, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .automatic)
    }
    
    private func onPersonModified(change: DocumentChange, person: Person) {
        if change.oldIndex == change.newIndex {
            let index = Int(change.oldIndex)
            people[index] = person
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            people.remove(at: Int(change.oldIndex))
            people.insert(person, at: Int(change.newIndex))
            tableView.moveRow(at: IndexPath(row: Int(change.oldIndex), section: 0), to: IndexPath(row: Int(change.newIndex), section: 0))
            tableView.reloadRows(at: [IndexPath(row: Int(change.newIndex), section: 0), IndexPath(row: Int(change.oldIndex), section: 0)], with: .automatic)
        }
    }
    
    private func onPersonRemoved(change: DocumentChange) {
        people.remove(at: Int(change.oldIndex))
        tableView.deleteRows(at: [IndexPath(row: Int(change.oldIndex), section: 0)], with: .automatic)
    }
    
    private func loadPeople() {
        Firestore.firestore().collection("List").getDocuments { snapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let personData = try! FirestoreDecoder().decode(Person.self, from: document.data())
                    var newPerson = Person(name: personData.name, image: personData.image, itemCount: personData.itemCount, items: personData.items)
                    newPerson.documentID = document.documentID
                    print(newPerson)
                    self.people.append(newPerson)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.itemsSegue:
            guard let listItemViewController = segue.destination as? ListItemViewController else { return }
            guard let person = person else { return }
            listItemViewController.selectedPerson = person
        default:
            break
        }
    }
}

// MARK: - TableViewExtension
extension ListSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.personCell, for: indexPath) as? PersonCell else { return UITableViewCell() }
        cell.configure(withImage: people[indexPath.row].image, withName: people[indexPath.row].name, withItemCount: people[indexPath.row].itemCount)
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        person = people[indexPath.row]
        performSegue(withIdentifier: SegueConstant.itemsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
