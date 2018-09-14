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
    
    let groupStorage: LocalJSONStore<[FeedGroup]> = LocalJSONStore(storageType: .permanent, filename: "groups.json")
    
    let imageStorage: LocalImageStore = LocalImageStore(storageType: .cache)
    
    var groups = [FeedGroup]()
    
    override init() {
        let all = FeedGroup(name: "All feeds")
        let nasaFeed = Feed()
        nasaFeed.url = "https://www.nasa.gov/rss/dyn/breaking_news.rss"
        all.feeds.append(nasaFeed)
        groups.append(all)
    }
}
