//
//  AppDelegate.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/3/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var cloudStore = CloudStore(persistentContainer: persistentContainer)
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WishListModel")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if var listSelectionCDVC = self.window?.rootViewController as? PersistentContainerRequiring {
            listSelectionCDVC.persistentContainer = persistentContainer
        }
        
        if var listSelectionCKVC = self.window?.rootViewController as? CloudStoreRequiring {
            listSelectionCKVC.cloudStore = cloudStore
        }
        
        cloudStore.subscribeToChangesIfNeeded { [weak self] error in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
            
            if error == nil {
                self?.cloudStore.fetchDatabaseChanges { fetchError in
                    if let error = fetchError {
                        print(error)
                    }
                }
            }
        }
        
        cloudStore.subscribeToSharedDatabase { [weak self] error in
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let dict = userInfo as? [String : NSObject] else {
            completionHandler(.failed)
            return
        }
        
        cloudStore.handleNotification(dict) { result in
            completionHandler(result)
        }
    }
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let acceptSharesOperation = CKAcceptSharesOperation(
            shareMetadatas: [cloudKitShareMetadata])
        
        acceptSharesOperation.perShareCompletionBlock = {
            metadata, share, error in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "")")
            } else {
                DispatchQueue.main.async {
                    guard let listSelectionVC = self.window?.rootViewController as? ListSelectionViewController else { return }
                    listSelectionVC.fetchShare(cloudKitShareMetadata)
                }
            }
        }
        
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier)
            .add(acceptSharesOperation)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        persistentContainer.saveContextIfNeeded()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        persistentContainer.saveContextIfNeeded()
    }
}





