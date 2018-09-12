//
//  LoginViewController.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import WeDeploy

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(_ sender: Any) {
        
        guard let loginText = loginTextField.text, let passwordText = passwordTextField.text else {
            return
        }
        
        WeDeploy.auth("https://auth-weread.wedeploy.io").signInWith(username: loginText, password: passwordText)
            .then { auth -> Void in
                
                WeDeployAPIClient.shared.userAuth = auth
                
                WeDeploy.auth("https://auth-weread.wedeploy.io", authorization: WeDeployAPIClient.shared.userAuth)
                .getCurrentUser()
                .then { user -> Void in
                    WeDeployAPIClient.shared.user = user
                    
                    self.performSegue(withIdentifier: "toMain", sender: nil)
                    //self.testWeDeployData()
                }
                
        }
        
    }
    
    func testWeDeployData() {
        
        guard let userId = WeDeployAPIClient.shared.user?.id else {
            print("could not load user")
            return
        }
        
        let feed = [
            "url": "www.g1.com",
            "name":"globonews",
            "userId": "\(userId)"
        ]
        
        WeDeploy.data("https://data-weread.wedeploy.io", authorization: WeDeployAPIClient.shared.userAuth).create(resource: "feeds", object: feed)
 
        WeDeploy.data("https://data-weread.wedeploy.io", authorization: WeDeployAPIClient.shared.userAuth).get(resourcePath: "feeds")
            .toCallback { result, error in
                print("Resultado: \(result?.debugDescription)")
                print(error.debugDescription)
        }
    }
    
    @IBAction func signup(_ sender: Any) {
        self.performSegue(withIdentifier: "toCreateAccount", sender: nil)
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
