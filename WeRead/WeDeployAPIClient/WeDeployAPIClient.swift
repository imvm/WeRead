//
//  WeDeployAPIClient.swift
//  WeRead
//
//  Created by Ian Manor on 11/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import Foundation
import WeDeploy

class WeDeployAPIClient {
    static let shared = WeDeployAPIClient()
    
    var userAuth: Auth?
    var user: User?
    
    func login() {
        guard userAuth == nil else {
            return
        }
        
        
    }
    
    func logout(callback: @escaping () -> ()) {
        guard  WeDeployAPIClient.shared.userAuth != nil else {
            print(userAuth)
            return
        }
        
        WeDeploy.auth("https://auth-weread.wedeploy.io", authorization: userAuth)
            .signOut()
        
        WeDeployAPIClient.shared.userAuth = nil
        WeDeployAPIClient.shared.user = nil
        
        callback()
    }
    
    func addFeed() {
        
    }
    
    func getFeeds() {
        
    }
    
}
