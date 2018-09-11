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
            myFeed.entries = entries.map({ (entry) -> Entry in
                let title = entry.title ?? "No title"
                let description = entry.summary?.value ?? "No description"
                let link = entry.content?.value
                let thumbnailLink = entry.media?.mediaThumbnails?.first?.value
                let date = entry.updated
                return Entry(feed: myFeed, title: title, description: description, link: link, thumbnailLink: thumbnailLink, date: date)
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
                
                let date = entry.pubDate
                
                return Entry(feed: myFeed, title: title, description: description, link: link, thumbnailLink: thumbnailLink, date: date)
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
                let date = item.datePublished
                return Entry(feed: myFeed, title: title, description: description, link: link, thumbnailLink: thumbnailLink, date: date)
            })
            
        case let .failure(error):
            completionHandler(nil, error)
        }
        
        completionHandler(myFeed, nil)
    }
}
