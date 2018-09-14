//
//  NotificationSender.swift
//  WeRead
//
//  Created by Ian Manor on 13/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationSender {
    static func sendNewsNotification(numberOfNewItems: Int, groups: [String]) {
        guard numberOfNewItems > 0, groups.count > 0 else {
            fatalError()
        }

        //get the notification center
        let center =  UNUserNotificationCenter.current()
        
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "WeRead News"
        var groupsSummary = groups.dropLast(max(groups.count - 2, 0)).joined(separator: ", ")
        if groups.count > 2 {
            groupsSummary.append(", ..")
        }
        let body = "\(numberOfNewItems) news from \(groupsSummary)."
        content.body = body
        content.sound = UNNotificationSound.default
        
        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: nil)
        
        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
}
