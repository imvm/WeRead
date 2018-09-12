//
//  CreateAccountViewController.swift
//  WeRead
//
//  Created by Ian Manor on 10/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit
import WeDeploy

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccount(_ sender: Any) {
        guard let emailText = emailTextfield.text,
        let passwordText = passwordTextField.text,
            let nameText = usernameTextField.text else {
                fatalError()
        }
        
        WeDeploy.auth("https://auth-weread.wedeploy.io")
            .createUser(email: emailText, password: passwordText, name: nameText)
            .toCallback { auth, error in
                if let _ = auth {
                    print(auth.debugDescription)
                }
                else {
                    print(error.debugDescription)
                }
        }
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancelCreation(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
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
