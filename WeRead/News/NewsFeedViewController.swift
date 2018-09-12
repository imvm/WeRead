//
//  MasterViewController.swift
//  WeRead
//
//  Created by Ian Manor on 06/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class NewsFeedViewController: UITableViewController {
    
    var filteredEntries = [Entry]()
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEntries = UserStore.shared.entries.filter({( entry : Entry) -> Bool in
            let doesCategoryMatch = (scope == "All") || (scope == "Favorites" && entry.favorite)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                let stringInTitle = entry.title?.lowercased().contains(searchText.lowercased())
                
                let stringInSummary = entry.summary?.lowercased().contains(searchText.lowercased())
                
                return doesCategoryMatch && (stringInTitle ?? false || stringInSummary ?? false)
            }
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Favorites"]
        searchController.searchBar.delegate = self
        
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
                
                let entry: Entry
                if isFiltering() {
                    entry = filteredEntries[indexPath.row]
                } else {
                    entry = UserStore.shared.entries[indexPath.row]
                }
                
                //controller.title = entry.title
                controller.detailItem = entry.link
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredEntries.count
        }
        
        return UserStore.shared.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsEntryCell", for: indexPath) as! NewsEntryCell
        
        cell.saveButton.tag = indexPath.row
        cell.saveButton.addTarget(self, action: #selector(self.saveEntry(_:)), for: .touchUpInside)
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(self.shareEntry(_:)), for: .touchUpInside)
        

        let entry: Entry
        if isFiltering() {
            entry = filteredEntries[indexPath.row]
        } else {
            entry = UserStore.shared.entries[indexPath.row]
        }

        cell.title!.text = entry.title
        cell.descriptionTextView.text = entry.summary
        
        if let date = entry.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            cell.pubDateLabel.text = dateFormatter.string(from: date)
        }
        
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
    
    @objc func saveEntry(_ sender: UIButton) {
        let entry: Entry
        if isFiltering() {
            entry = filteredEntries[sender.tag]
        } else {
            entry = UserStore.shared.entries[sender.tag]
        }
        
        entry.favorite = !entry.favorite
        
        if entry.favorite {
            sender.setTitleColor(.green, for: .normal)
            sender.setImage(UIImage(named: "star"), for: .normal)
        } else {
            sender.setTitleColor(.red, for: .normal)
            sender.setImage(UIImage(named: "icons8-star-50"), for: .normal)
        }
    }
    
    @objc func shareEntry(_ sender: UIButton) {
        let entry: Entry
        if isFiltering() {
            entry = filteredEntries[sender.tag]
        } else {
            entry = UserStore.shared.entries[sender.tag]
        }
        
        guard let title = entry.title, let image = entry.image, let summary = entry.summary, let shareLink = entry.link, let shareURL = URL(string: shareLink) else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [title, summary, image,  shareURL], applicationActivities: [])
        present(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    /*
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Get current state from data source
        //guard let favorite = dataSource?.favorite(at: indexPath) else {
        //    return nil
        //}
        
        let favorite = UserStore.shared.entries[indexPath.row].favorite
        
        let title = favorite ?
            NSLocalizedString("Unfavorite", comment: "Unfavorite") :
            NSLocalizedString("Favorite", comment: "Favorite")
        
        let action = UIContextualAction(style: .normal, title: title,
                                        handler: { (action, view, completionHandler) in
                                            // Update data source when user taps action
                                            UserStore.shared.entries[indexPath.row].favorite = !favorite
                                            
                                            //self.dataSource?.setFavorite(!favorite, at: indexPath)
                                            completionHandler(true)
        })
        
        action.image = UIImage(named: "heart")
        action.backgroundColor = favorite ? .red : .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

     */
}

extension NewsFeedViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension NewsFeedViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
