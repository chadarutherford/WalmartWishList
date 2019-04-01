//
//  ListSelectionViewController.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 3/22/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData

class ListSelectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var lists = [List]()
    var listTitle: String?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Helper Methods
    func loadData() {
    }
    
    func list(at indexPath: IndexPath) -> List {
        return lists[indexPath.row]
    }
    
//    private func prepareToShare(share: CKShare, record: CKRecord) {
//        let sharingViewController = UICloudSharingController { (UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
//            let modRecordsList = CKModifyRecordsOperation(recordsToSave: [record, share], recordIDsToDelete: nil)
//            modRecordsList.modifyRecordsCompletionBlock = { record, recordID, error in
//                handler(share, CKContainer.default(), error)
//            }
//            CKContainer.default().privateCloudDatabase.add(modRecordsList)
//        }
//        sharingViewController.delegate = self
//        sharingViewController.availablePermissions = [.allowReadWrite, .allowPrivate]
//        present(sharingViewController, animated: true)
//    }
    
    // MARK: - Actions
    @IBAction func addTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueConstant.addList, sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueConstant.addList:
            guard let addListVC = segue.destination as? AddListViewController else { return }
        case SegueConstant.listSelected:
            guard let listViewVC = segue.destination as? ListViewViewController else { return }
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConstant.listCell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SegueConstant.listSelected, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
    }
}

extension ListSelectionViewController: UICloudSharingControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return ""
    }
    
    
}
