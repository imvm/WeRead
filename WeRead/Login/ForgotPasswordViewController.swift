//
//  ForgotPasswordViewController.swift
//  WeRead
//
//  Created by Ian Manor on 11/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        emailTextField.delegate = textFieldDelegate
        emailTextField.tag = 0
    }
    
    @IBAction func sendPasswordResetEmail(_ sender: Any) {
        guard let emailText = emailTextField.text else {
            return
        }
        
        resetPasswordButton.isEnabled = false
        
        WeDeployAPIClient.shared.resetPassword(emailText: emailText) { isSuccessful in
            if isSuccessful {
                self.dismiss(animated: false, completion: nil)
            } else {
                self.resetPasswordButton.isEnabled = true
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
