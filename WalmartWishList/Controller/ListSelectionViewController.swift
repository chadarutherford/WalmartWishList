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
    private var people = [Person]()
    
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadPeople()
        print(people)
    }
    
    // MARK: - Helper Methods
    private func loadPeople() {
        Firestore.firestore().collection("List").getDocuments { snapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            } else {
                guard let snapshot = snapshot else { return }
                for document in snapshot.documents {
                    let personData = try! FirestoreDecoder().decode(Person.self, from: document.data())
                    let newPerson = Person(name: personData.name, image: personData.image, itemCount: personData.itemCount, items: personData.items)
                    self.people.append(newPerson)
                    self.tableView.reloadData()
                }
            }
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
