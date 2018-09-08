//
//  FeedLoader.swift
//  WeRead
//
//  Created by Ian Manor on 08/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import FeedKit

class FeedLoader: NSObject {
    static func loadFeed(feed: String, completionHandler: @escaping (Feed?, Error?) -> Void) {
        //RSS Feed examples
        //https://www.nasa.gov/rss/dyn/breaking_news.rss
        //http://rss.cnn.com/rss/cnn_topstories.rss
        //http://feeds.nytimes.com/nyt/rss/HomePage
        
        //TODO: PARSING ERROR!!!
        //http://www.washingtonpost.com/rss/
        
        let feedURL = URL(string: feed)!
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data) or FeedParser(xmlStream: stream)
        let myFeed = Feed()
        
        let result = parser.parse()
        
        switch result {
        // Atom Syndication Format Feed Model
        case let .atom(feed):
            guard let entries = feed.entries else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.map({ (entry) -> Entry in
                let title = entry.title ?? "No title"
                let description = entry.summary?.value ?? "No description"
                let link = entry.content?.value
                let thumbnailLink = entry.media?.mediaThumbnails?.first?.value
                return Entry(title: title, description: description, link: link, thumbnailLink: thumbnailLink)
            })
            
        // Really Simple Syndication Feed Model
        case let .rss(feed):
            guard let entries = feed.items else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.map({ (entry) -> Entry in
                let title = entry.title ?? "No title"
                let description = entry.description ?? "No description"
                let link = entry.link
                var thumbnailLink = entry.enclosure?.attributes?.url
                
                if thumbnailLink == nil {
                    thumbnailLink = entry.media?.mediaGroup?.mediaContents?.first?.attributes?.url
                }
                
                if thumbnailLink == nil {
                    thumbnailLink = entry.media?.mediaContents?.first?.attributes?.url
                }
                
                return Entry(title: title, description: description, link: link, thumbnailLink: thumbnailLink)
            })
            
        // JSON Feed Model
        case let .json(feed):
            guard let entries = feed.items else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.map({ (item) -> Entry in
                let title = item.title ?? "No title"
                let description = item.summary ?? "No description"
                let link = item.url
                let thumbnailLink = item.image
                return Entry(title: title, description: description, link: link, thumbnailLink: thumbnailLink)
            })
            
        case let .failure(error):
            completionHandler(nil, error)
        }
        
        completionHandler(myFeed, nil)
    }
}
