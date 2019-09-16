//
//  ListDataSource.swift
//  CloudWishList
//
//  Created by Chad Rutherford on 5/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit


class ListDataSource: NSObject, UITableViewDataSource {
    
    var cellIdentifier: String
    var tableView: UITableView
    var dataProvider: DataProvider!
    
    
    init(cellIdentifier: String, tableView: UITableView, dataProvider: DataProvider) {
        self.cellIdentifier = cellIdentifier
        self.tableView = tableView
        self.dataProvider = dataProvider
        super.init()
        self.dataProvider.delegate = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataProvider.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataProvider.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        let list = dataProvider.object(at: indexPath)
        cell.textLabel?.text = list.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let objectToDelete = self.dataProvider.object(at: indexPath)
        self.dataProvider.delete(list: objectToDelete)
    }
}

extension ListDataSource: DataProviderDelegate {
    func dataProviderDidInsert(indexPath: IndexPath) {
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func dataProviderDidDelete(indexPath: IndexPath) {
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func dataProviderDidUpdate(indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func dataProviderDidMove(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        self.tableView.moveRow(at: indexPath, to: newIndexPath)
    }
    
    
}
