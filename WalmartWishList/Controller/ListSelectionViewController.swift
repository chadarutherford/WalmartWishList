//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseDatabase

final class ListSelectionViewController: UIViewController, PersonDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var people: [Person]?
    private let realm = try? Realm()
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadPeople()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - PersonDelegate Methods
    func convertInputToPerson(name: String, image: Data) {
        let newPerson = Person(name: name, image: image)
        do {
            try realm?.write {
                realm?.add(newPerson)
            }
        } catch let error {
            print(error)
        }
        tableView.reloadData()
    }
    
    // MARK: - Helper Methods
    private func loadPeople() {
        guard let results = realm?.objects(Person.self) else { return }
        people = Array(results)
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.addPersonSegue:
            guard let destinationVC = segue.destination as? AddPersonViewController else { return }
            destinationVC.delegate = self
        case SegueConstant.itemsSegue:
            guard let destinationVC = segue.destination as? ListItemViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destinationVC.selectedPerson = people?[indexPath.row]
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
        return people?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.personCell, for: indexPath) as? PersonCell else { return UITableViewCell() }
        if let person = people?[indexPath.row] {
            guard let image = UIImage(data: person.image) else { fatalError() }
            cell.configure(withImage: image, withName: person.name, withItemCount: person.itemCount)
        }
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
