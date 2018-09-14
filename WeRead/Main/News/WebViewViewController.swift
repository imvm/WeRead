//
//  DetailViewController.swift
//  WeRead
//
//  Created by Ian Manor on 06/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var webView: WKWebView!

    func configureView() {
        if self.webView == nil {
            self.webView = WKWebView(frame: self.view.frame)
            self.view.addConstrained(subview: webView)
        }
        
        // Update the user interface for the detail item.
        if let detail = detailItem, let url = URL(string: detail) {
            webView.load(URLRequest(url: url))
            
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        edgesForExtendedLayout = []
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.prefersLargeTitles = false
        self.navigationController!.navigationBar.isTranslucent = false
    }

    var detailItem: String? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func initWebView() {
    }


}

extension UIView {
    func addConstrained(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
