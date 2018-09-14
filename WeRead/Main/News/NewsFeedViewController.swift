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
    var group: FeedGroup!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Private instance methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if group == nil {
            group = UserStore.shared.groups.first!
        }
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = NSLocalizedString("News", comment: "")

        tableView.register(UINib(nibName: "NewsEntryCell", bundle: nil), forCellReuseIdentifier: "NewsEntryCell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(NewsFeedViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        refreshFeeds()

    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Favorites"]
        searchController.searchBar.delegate = self
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        if !refreshControl.isRefreshing {
            refreshFeeds()
        }
    }
    
    func refreshFeeds() {
        DispatchQueue.global(qos: .background).async {
            self.loadFeeds {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func loadFeeds(completion: @escaping () -> ()) {
        if group.feeds.count == 0 {
            DispatchQueue.main.async {
                completion()
            }
        }
        
        for feed in group.feeds {
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

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! WebViewViewController
                
                let entry: Entry
                if isFiltering() {
                    entry = filteredEntries[indexPath.row]
                } else {
                    entry = group.entries[indexPath.row]
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
        
        return group.entries.count
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
            entry = group.entries[indexPath.row]
        }

        cell.title!.text = entry.title
        cell.descriptionTextView.text = entry.summary
        
        if let date = entry.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
            cell.pubDateLabel.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
    
    @objc func saveEntry(_ sender: UIButton) {
        let entry: Entry
        if isFiltering() {
            entry = filteredEntries[sender.tag]
        } else {
            entry = group.entries[sender.tag]
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
            entry = group.entries[sender.tag]
        }
        
        guard let title = entry.title, /*let image = entry.image,*/ let summary = entry.summary, let shareLink = entry.link, let shareURL = URL(string: shareLink) else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [title, summary, /*image,*/  shareURL], applicationActivities: [])
        present(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showWebView", sender: self)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEntries = group.entries.filter({( entry : Entry) -> Bool in
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
