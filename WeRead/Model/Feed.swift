//
//  Feed.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class Feed: NSObject {
    var url: String? = nil
    var name: String? = nil
    var entries: [Entry]? = nil
    var favorite: Bool = false
}
