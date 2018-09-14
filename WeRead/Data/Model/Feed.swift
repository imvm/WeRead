//
//  Feed.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class Feed: NSObject, Codable {
    var url: String? = nil
    var name: String? = nil
    var entries: [Entry]? = nil
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherFeed = object as? Feed else {
            return false
        }
        
        if self.name == otherFeed.name || self.url == otherFeed.url {
            return true
        }
        
        return false
    }
}
