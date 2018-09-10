//
//  MasterViewController.swift
//  WeRead
//
//  Created by Ian Manor on 06/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class Feed: NSObject {
    var name: String? = nil
    var entries: [Entry]? = nil
    var favorite: Bool = false
}

class Entry: NSObject {
    let title: String?
    let summary: String?
    let link: String?
    let thumbnailLink: String?
    var image: UIImage?
    var favorite: Bool = false
    
    init(title: String?, description: String?, link: String?, thumbnailLink: String?) {
        self.title = title
        self.summary = description
        self.link = link
        self.thumbnailLink = thumbnailLink
    }
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var feed: Feed?
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.global(qos: .background).async {
            self.loadFeed {
                refreshControl.endRefreshing()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "NewsEntryCell", bundle: nil), forCellReuseIdentifier: "NewsEntryCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        DispatchQueue.global(qos: .background).async {
            self.loadFeed {
                self.title = self.feed?.name
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    func loadFeed(completion: @escaping () -> ()) {
        FeedLoader.loadFeed(feed: "https://www.nasa.gov/rss/dyn/breaking_news.rss") { (result, error) in
            guard error == nil else {
                fatalError(error.debugDescription)
            }
            
            self.feed = result
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
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
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                guard let entry = feed?.entries?[indexPath.row] else {
                    fatalError()
                }
                
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
        return feed?.entries?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsEntryCell", for: indexPath) as! NewsEntryCell

        guard let entry = feed?.entries?[indexPath.row] else {
            fatalError()
        }

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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            feed?.entries?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Get current state from data source
        //guard let favorite = dataSource?.favorite(at: indexPath) else {
        //    return nil
        //}
        
        guard let favorite = feed?.entries?[indexPath.row].favorite else {
            return nil
        }
        
        let title = favorite ?
            NSLocalizedString("Unfavorite", comment: "Unfavorite") :
            NSLocalizedString("Favorite", comment: "Favorite")
        
        let action = UIContextualAction(style: .normal, title: title,
                                        handler: { (action, view, completionHandler) in
                                            // Update data source when user taps action
                                            self.feed?.entries?[indexPath.row].favorite = !favorite
                                            //self.dataSource?.setFavorite(!favorite, at: indexPath)
                                            completionHandler(true)
        })
        
        action.image = UIImage(named: "heart")
        action.backgroundColor = favorite ? .red : .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }


}
