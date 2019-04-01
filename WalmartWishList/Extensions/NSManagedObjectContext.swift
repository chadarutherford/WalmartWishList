//
//  NSManagedObjectContext.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/1/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    func persist(block: @escaping () -> ()) {
        perform {
            block()
            
            do {
                try self.save()
            } catch {
                self.rollback()
            }
        }
    }
}
