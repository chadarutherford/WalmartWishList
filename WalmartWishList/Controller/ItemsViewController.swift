//
//  ItemsViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 1/16/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    
    var person: Person?
    var items = [ItemObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let person = person else { return }
        items = person.items
    }
}

extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.itemsCell, for: indexPath)
        return cell
    }
}
