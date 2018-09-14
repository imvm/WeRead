//
//  Entry.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import FeedKit

class Entry: NSObject, Codable {
    let id: String
    let title: String?
    let summary: String?
    let link: String?
    let thumbnailLink: String?
    let date: Date?
    var favorite: Bool = false
    weak var feed: Feed!
    
    init?(item: JSONFeedItem, feed: Feed) {
        self.feed = feed
        
        guard let id = item.id else {
            return nil
        }
        
        self.id = id
        self.title = item.title ?? "No title"
        self.summary = item.summary ?? "No description"
        self.link = item.url
        self.thumbnailLink = item.image
        self.date = item.datePublished
        
        super.init()
    }
    
    init?(entry: AtomFeedEntry, feed: Feed) {
        
        guard let id = entry.id else {
            return nil
        }
    
        self.id = id
        self.title = entry.title ?? "No title"
        self.summary = entry.summary?.value ?? "No description"
        self.link = entry.content?.value
        self.thumbnailLink = entry.media?.mediaThumbnails?.first?.value
        self.date = entry.updated
        
        super.init()
    }
    
    init?(entry: RSSFeedItem, feed: Feed) {
        self.feed = feed
        
        
        guard let id = entry.guid?.value else {
            return nil
        }
        
        self.id = id
        self.title = entry.title ?? "No title"
        self.summary = entry.description ?? "No description"
        self.link = entry.link
        
        if let thumbnailLink = entry.enclosure?.attributes?.url {
            self.thumbnailLink = thumbnailLink
        } else if let thumbnailLink = entry.media?.mediaGroup?.mediaContents?.first?.attributes?.url {
            self.thumbnailLink = thumbnailLink
        } else {
            self.thumbnailLink = entry.media?.mediaContents?.first?.attributes?.url
        }
        
        self.date = entry.pubDate
        
        super.init()
        
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherEntry = object as? Entry else {
            return false
        }
        
        if self.id == otherEntry.id {
            return true
        }
        
        return false
    }
    
}
