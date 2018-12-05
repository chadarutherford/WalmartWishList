//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import RealmSwift

class ListSelectionViewController: UIViewController, PersonDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var people: Results<Person>?
    let realm = try? Realm()
    
    // MARK: - ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        loadPeople()
    }
    
    // MARK: - Actions
    
    // MARK: - PersonDelegate Methods
    func convertInputToPerson(name: String, image: String) {
        let newPerson = Person()
        newPerson.name = name
        newPerson.image = image
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
    func loadPeople() {
        people = realm?.objects(Person.self)
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.addPersonSegue:
            guard let destinationVC = segue.destination as? AddPersonViewController else { return }
            destinationVC.delegate = self
        default:
            break
        }
    }
}

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
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        if let person = people?[indexPath.row] {
            if let filePath = documentsURL?.appendingPathComponent("\(person.image).jpg").path {
                if fileManager.fileExists(atPath: filePath) {
                    cell.personImageView.image = UIImage(contentsOfFile: filePath)
                } else {
                    cell.personImageView.image = UIImage(named: "profile_default")
                }
            }
            cell.nameLabel.text = person.name
            cell.itemCountLabel.text = "Items: \(person.itemCount)"
        }
        
        return cell
    }
    
    // MARK: - TableViewDelegate Methods
}
