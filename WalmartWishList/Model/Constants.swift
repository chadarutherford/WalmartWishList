//
//  Constants.swift
//  WalmartWishList
//
//  Created by Chad Rutherford on 12/4/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Foundation

struct CellConstant {
    static let personCell = "PersonCell"
}

struct SegueConstant {
    static let addPersonSegue = "addPerson"
}

//guard let url = URL(string: "https://api.walmartlabs.com/v1/search?apiKey=5cjczkw7a8ghwxduvgwrhk4v&query=ipod") else { return }
//
//URLSession.shared.dataTask(with: url) { data, response, error in
//    guard let data = data else { return }
//    do {
//        let itemInfo = try JSONDecoder().decode(ListItem.self, from: data)
//
//        DispatchQueue.main.async {
//            print(itemInfo)
//        }
//    } catch let error {
//        print(error)
//    }
//    }.resume()
