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
    var favorites = [Entry]()
}
