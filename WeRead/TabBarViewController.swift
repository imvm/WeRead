//
//  TabBarViewController.swift
//  WeRead
//
//  Created by Ian Manor on 08/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.delegate = self
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let newsController = viewController.children.first as? NewsFeedViewController {
            DispatchQueue.global(qos: .background).async {
                newsController.loadFeeds {
                    DispatchQueue.main.async {
                        newsController.tableView.reloadData()
                    }
                }
            }
        } else if let tableViewController = self.selectedViewController as? UITableViewController {
            tableViewController.tableView.reloadData()
        }
    }
}
