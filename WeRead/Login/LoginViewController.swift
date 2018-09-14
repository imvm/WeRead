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
                UIApplication.shared.setMinimumBackgroundFetchInterval(
                    UIApplication.backgroundFetchIntervalMinimum)
                self.performSegue(withIdentifier: "toMain", sender: nil)
            } else {
                self.alertFailedLogin()
                self.loginButton.isEnabled = true
            }
        }
        
    }
    
    func alertFailedLogin() {
        let alert = UIAlertController(title: NSLocalizedString("Failed", comment: ""), message: NSLocalizedString("Could not log in :(", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func enterWithoutLogin(_ sender: Any) {
        UIApplication.shared.setMinimumBackgroundFetchInterval(
        UIApplication.backgroundFetchIntervalMinimum)
        self.performSegue(withIdentifier: "toMain", sender: nil)
    }
}

