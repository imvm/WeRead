//
//  FeedGroup.swift
//  WeRead
//
//  Created by Ian Manor on 13/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class FeedGroup: NSObject, Codable {
    var name: String
    var feeds = [Feed]()
    
    init(name: String) {
        self.name = name
    }
    
    var entries: [Entry] {
        return feeds
            .compactMap{ $0.entries }
            .flatMap { $0 }
            .removingDuplicates()
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherFeedGroup = object as? FeedGroup else {
            return false
        }
        
        if self.name == otherFeedGroup.name {
            return true
        }
        
        return false
    }
}
