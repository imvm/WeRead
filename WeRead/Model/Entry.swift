//
//  Entry.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class Entry: NSObject, Codable {
    let title: String?
    let summary: String?
    let link: String?
    let thumbnailLink: String?
    let date: Date?
    var favorite: Bool = false
    weak var feed: Feed!
    
    init(feed: Feed, title: String?, description: String?, link: String?, thumbnailLink: String?, date: Date?) {
        self.feed = feed
        self.title = title
        self.summary = description
        self.link = link
        self.thumbnailLink = thumbnailLink
        self.date = date
    }
}
