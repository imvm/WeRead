//
//  FeedTableViewController.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import WeDeploy

class FeedTableViewController: UITableViewController {

    var groups: [FeedGroup] = UserStore.shared.groups
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.title = "Feeds"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FeedTableViewController.showAddFeedAlert))
        
        if WeDeployAPIClient.shared.user != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(FeedTableViewController.logout))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(FeedTableViewController.goToLogin))
        }
        
        if let storedGroups = UserStore.shared.groupStorage.storedValue {
            groups = [groups.first!] + storedGroups
        }
        
    }
    
    @objc func logout() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalNever)
        
        WeDeployAPIClient.shared.logout {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func goToLogin() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        UIApplication.shared.windows.first!.rootViewController = loginVC
    }
    
    @objc func showAddFeedAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Add new feed URL", comment: ""), message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.keyboardType = .webSearch
            
            if let pasteboardString = UIPasteboard.general.string, pasteboardString.contains(".rss") || pasteboardString.contains(".xml") || pasteboardString.contains(".json") {
                textField.text = pasteboardString
            }
        }
        
        alertController.modalPresentationStyle = .overFullScreen
        
        //We add buttons to the alert controller by creating UIAlertActions:
        let actionOk = UIAlertAction(title: "OK", style: .default) { (action) in
            guard var urlString = alertController.textFields![0].text else {
                return
            }
            
            let feedPrefix = "feed://"
            if urlString.hasPrefix(feedPrefix) {
                urlString.removeFirst(feedPrefix.count)
            }
            
            self.addURL(urlString)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alertController.addAction(actionOk)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addURL(_ urlString: String) {
        let newFeed = Feed()
        newFeed.url = urlString
        
        let newFeedGroup = FeedGroup(name: urlString)
        groups.append(newFeedGroup)
        
        //TODO
        //add URL to WeData
        let groupsToSave = Array(groups.dropFirst())
        UserStore.shared.groupStorage.save(groupsToSave)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath)

        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDetail" {
            let newsFeedVC = segue.destination.children.first! as! NewsFeedViewController
            let selectedGroup = groups[tableView.indexPathForSelectedRow!.row]
            newsFeedVC.group = selectedGroup
        }
    }
    
}
