//
//  UserStore.swift
//  WeRead
//
//  Created by Ian Manor on 11/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class UserStore: NSObject {
    static let shared = UserStore()
    
    var feeds = [Feed]()
    
    var entries: [Entry] {
        return UserStore.shared.feeds
            .compactMap{ $0.entries }
            .flatMap { $0 }
            .sorted(by: {
                if let firstDate = $0.date {
                    if let secondDate = $1.date {
                        return firstDate > secondDate
                    } else {
                        return true
                    }
                }
                return false
            })
    }
    
    var favorites: [Entry] {
        return entries.filter{ $0.favorite }
    }
}
