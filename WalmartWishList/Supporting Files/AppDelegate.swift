//
//  AppDelegate.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/3/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import UIKit
import CoreData
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
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
        if var listSelectionVC = self.window?.rootViewController as? PersistentContainerRequiring {
            listSelectionVC.persistentContainer = persistentContainer
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        persistentContainer.saveContextIfNeeded()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        persistentContainer.saveContextIfNeeded()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received push!")
    }
}





