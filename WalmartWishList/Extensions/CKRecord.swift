//
//  CKRecord.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 4/2/19.
//  Copyright © 2019 Chad A. Rutherford. All rights reserved.
//

import CloudKit

extension CKRecord {
    var encodedSystemFields: Data {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        self.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        return coder.encodedData
    }
}
