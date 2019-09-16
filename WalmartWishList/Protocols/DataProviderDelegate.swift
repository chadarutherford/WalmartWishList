//
//  DataSourceDelegate.swift
//  CloudWishList
//
//  Created by Chad Rutherford on 5/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import Foundation

protocol DataProviderDelegate: AnyObject {
    func dataProviderDidInsert(indexPath: IndexPath)
    func dataProviderDidDelete(indexPath: IndexPath)
    func dataProviderDidUpdate(indexPath: IndexPath)
    func dataProviderDidMove(at indexPath: IndexPath, to newIndexPath: IndexPath)
}
