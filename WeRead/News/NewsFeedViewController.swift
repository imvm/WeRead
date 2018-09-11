//
//  MasterViewController.swift
//  WeRead
//
//  Created by Ian Manor on 06/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class NewsFeedViewController: UITableViewController {
    
    var entries: [Entry] {
        return UserStore.shared.feeds
        .compactMap{ $0.entries }
            .flatMap { $0 }.sorted(by: { (entryA, entryB) -> Bool in
                if let firstDate = entryA.date {
                    if let secondDate = entryB.date {
                        return firstDate < secondDate
                    } else {
                        return true
                    }
                } else {
                    return false
                }
            })
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.global(qos: .background).async {
            self.loadFeeds {
                self.tableView.reloadData()
                refreshControl.endRefreshing()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "News"
        
        tableView.register(UINib(nibName: "NewsEntryCell", bundle: nil), forCellReuseIdentifier: "NewsEntryCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(NewsFeedViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        DispatchQueue.global(qos: .background).async {
            self.loadFeeds {
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LoginViewController.logout))

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton

    }
    
    func loadFeeds(completion: @escaping () -> ()) {
        for feed in UserStore.shared.feeds {
            loadFeed(feed, completion)
        }
    }
    
    func loadFeed(_ feed: Feed, _ completion: @escaping () -> ()) {
        FeedLoader.loadFeed(feed) { (result, error) in
            guard error == nil else {
                fatalError(error.debugDescription)
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        //entries.insert(NSDate(), at: 0)
        //let indexPath = IndexPath(row: 0, section: 0)
        //tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! WebViewViewController
                
                let entry = entries[indexPath.row]
                
                controller.title = entry.title
                controller.detailItem = entry.link
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let entries = UserStore.shared.feeds
            .compactMap{ $0.entries }
            .flatMap { $0 }
        
        return entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsEntryCell", for: indexPath) as! NewsEntryCell

        let entry = entries[indexPath.row]

        cell.title!.text = entry.title
        cell.descriptionTextView.text = entry.summary
        
        if entry.image != nil {
            cell.entryImage.image = entry.image
        } else {
            if let thumbnailLink = entry.thumbnailLink, let thumbnailURL = URL(string: thumbnailLink) {
                DispatchQueue.global(qos: .background).async {
                    do {
                        let thumbnailImage =  try UIImage(data: Data(contentsOf: thumbnailURL))
                    
                        DispatchQueue.main.async {
                            cell.entryImage.image = thumbnailImage
                            entry.image = thumbnailImage
                        }
                    } catch {
                        print("error loading enclosure image")
                    }
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Get current state from data source
        //guard let favorite = dataSource?.favorite(at: indexPath) else {
        //    return nil
        //}
        
        let favorite = entries[indexPath.row].favorite
        
        let title = favorite ?
            NSLocalizedString("Unfavorite", comment: "Unfavorite") :
            NSLocalizedString("Favorite", comment: "Favorite")
        
        let action = UIContextualAction(style: .normal, title: title,
                                        handler: { (action, view, completionHandler) in
                                            // Update data source when user taps action
                                            self.entries[indexPath.row].favorite = !favorite
                                            
                                            //self.dataSource?.setFavorite(!favorite, at: indexPath)
                                            completionHandler(true)
        })
        
        action.image = UIImage(named: "heart")
        action.backgroundColor = favorite ? .red : .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }


}
