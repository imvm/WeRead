//
//  WeDeployAPIClient.swift
//  WeRead
//
//  Created by Ian Manor on 11/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import WeDeploy

class WeDeployAPIClient {
    static let shared = WeDeployAPIClient()
    
    var userAuth: Auth?
    var user: User?
    
    let authURL = "https://auth-weread.lfr.io"
    let dataURL = "https://data-weread.lfr.io"
    
    //TODO: Better error handling
    
    func login(loginText: String, passwordText: String, callback: @escaping (Bool) -> ()) {
        guard userAuth == nil else {
            fatalError()
        }
        print(authURL)
        
        WeDeploy.auth(authURL)
        .signInWith(username: loginText, password: passwordText)
        .then { auth -> Void in
            WeDeployAPIClient.shared.userAuth = auth
            callback(true)
        } .catch { error in
            if let error = error as? WeDeployError {
                print(error.errors)
                print(error.code)
                print(error.message)
            }
            
            callback(false)
        }
    }
    
    func getCurrentUser(callback: @escaping (Bool) -> ()) {
        WeDeploy.auth(authURL, authorization: WeDeployAPIClient.shared.userAuth)
        .getCurrentUser()
        .then { user -> Void in
            WeDeployAPIClient.shared.user = user
            callback(true)
        }
        .catch{ _ in
            callback(false)
        }
    }
    
    func logout(callback: @escaping () -> ()) {
        guard  WeDeployAPIClient.shared.userAuth != nil else {
            callback()
            return
        }
        
        WeDeploy.auth(authURL, authorization: userAuth)
        .signOut()
        
        WeDeployAPIClient.shared.userAuth = nil
        WeDeployAPIClient.shared.user = nil
        
        callback()
    }
    
    func createUser(emailText: String, nameText: String, passwordText: String, callback: @escaping (Bool) -> ()) {
        WeDeploy.auth(authURL)
        .createUser(email: emailText, password: passwordText, name: nameText)
        .toCallback { auth, error in
            if let _ = auth {
                print("created account")
                print(auth)
                callback(true)
            }
            else if let error = error as? WeDeployError {
                print(error.errors)
                print(error.code)
                print(error.message)
                callback(false)
            }
        }
    }
    
    func resetPassword(emailText: String, callback: @escaping (Bool) -> ()) {
        WeDeploy.auth(authURL)
        .sendPasswordReset(email: emailText)
        .then {
            callback(true)
        }
        .catch { _ in
            callback(false)
        }

    }
    
    func addFeed() {
       //WeDeploy.data(dataURL, authorization: auth).post
    }
    
    func getFeeds() {
        //WeDeploy.data(dataURL, authorization: auth).get
    }
    
}
