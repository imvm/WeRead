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
    
    @IBOutlet weak var loginButton: UIButton!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        loginTextField.delegate = textFieldDelegate
        loginTextField.tag = 0
        
        passwordTextField.delegate = textFieldDelegate
        passwordTextField.tag = 1
    }
    
    @IBAction func login(_ sender: Any) {
        
        loginButton.isEnabled = false
        
        guard let loginText = loginTextField.text, let passwordText = passwordTextField.text else {
            return
        }
        
        WeDeployAPIClient.shared.login(loginText: loginText, passwordText: passwordText) { isSuccessful in
            if isSuccessful {
                self.performSegue(withIdentifier: "toMain", sender: nil)
            } else {
                self.loginButton.isEnabled = true
            }
        }
        
    }

}

