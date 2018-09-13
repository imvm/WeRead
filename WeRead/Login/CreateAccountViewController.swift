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
    @IBOutlet weak var createAccountButton: UIButton!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        emailTextfield.delegate = textFieldDelegate
        emailTextfield.tag = 0
        
        usernameTextField.delegate = textFieldDelegate
        usernameTextField.tag = 1
        
        passwordTextField.delegate = textFieldDelegate
        passwordTextField.tag = 2
    }
    
    @IBAction func createAccount(_ sender: Any) {
        createAccountButton.isEnabled = false
        
        guard let emailText = emailTextfield.text,
        let passwordText = passwordTextField.text,
            let nameText = usernameTextField.text else {
                fatalError()
        }
        
        WeDeployAPIClient.shared.createUser(emailText: emailText, nameText: nameText, passwordText: passwordText) { isSuccessful in
            if isSuccessful {
                self.dismiss(animated: false, completion: nil)
            } else {
                self.createAccountButton.isEnabled = false
            }
        }
        
    }
    
    @IBAction func cancelCreation(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
