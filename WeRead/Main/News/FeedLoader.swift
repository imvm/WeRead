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
    
    static func loadFeed(_ myFeed: Feed, completionHandler: @escaping (Feed?, Error?) -> Void) {
        //RSS Feed examples
        //https://www.nasa.gov/rss/dyn/breaking_news.rss
        //http://rss.cnn.com/rss/cnn_topstories.rss
        //http://feeds.nytimes.com/nyt/rss/HomePage
        
        //TODO: PARSING ERROR!!!
        //http://www.washingtonpost.com/rss/
        
        let feedURL = URL(string: myFeed.url!)!
        let parser = FeedParser(URL: feedURL) // or FeedParser(data: data) or FeedParser(xmlStream: stream)
        
        let result = parser.parse()
        
        switch result {
        // Atom Syndication Format Feed Model
        case let .atom(feed):
            guard let entries = feed.entries else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.compactMap({ (entry) -> Entry? in
                return Entry(entry: entry, feed: myFeed)
            })
            
        // Really Simple Syndication Feed Model
        case let .rss(feed):
            guard let entries = feed.items else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.compactMap({ (entry) -> Entry? in
                return Entry(entry: entry, feed: myFeed)
            })
            
        // JSON Feed Model
        case let .json(feed):
            guard let entries = feed.items else { fatalError() }
            myFeed.name = feed.title
            myFeed.entries = entries.compactMap({ (item) -> Entry? in
                return Entry(item: item, feed: myFeed)
            })
            
        case let .failure(error):
            completionHandler(nil, error)
            return
        }
        
        completionHandler(myFeed, nil)
    }
}
