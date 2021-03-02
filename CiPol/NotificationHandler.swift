//
//  NotificationHandler.swift
//  CI-Monitor
//
//  Created by Ron Dorn on 2/8/21.
//

import UserNotifications
import Cocoa

class NotificationHandler {
    
    var isInTest = false
    
    init(){
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            isInTest = true
        }
    }
    
    func showNotification(title: String , message: String) {
        
        var notificationMessage = message
        notificationMessage = notificationMessage.replacingOccurrences(of: "\n", with: ", ")

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = notificationMessage
        if (isInTest == false){
            content.sound = UNNotificationSound.default
        }
        content.categoryIdentifier = "Alert"
        
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        print ("Exiting NotificationHandler")
        
        let application = NSApplication.shared
        let state = application.isActive
        
        if (state || isInTest == true){
            _ = Toast.displayMesssage(title: title,message: message)
        }
    }
    
    func showNotification(jobName: String, jobStatus: String) -> Void {
        
        let icon = Utilties.getPassFailIcon(status: jobStatus)
        var iconText = ""
        

        if jobStatus == Utilties.testPassed {
            iconText = "\(icon) \(jobName) Passing"
            
        } else if jobStatus == Utilties.testFailed {
            iconText = "\(icon) \(jobName) Failing"
        
        } else {
            iconText = "\(icon) \(jobName) Unknown"
        }
        
        let message = "Jenkins job \(jobName) now \(jobStatus)"
        
        print ("Entering NotificationHandler")
        
        self.showNotification(title: iconText, message: message)
 
    }
    
    func showNotification(jobNames: [String], jobStatus: String) -> Void {
        
        let icon = Utilties.getPassFailIcon(status: jobStatus)
        var iconText = ""
        

        if jobStatus == Utilties.testPassed {
            iconText = "\(icon) Multiple Jobs Are Now Passing"
            
        } else if jobStatus == Utilties.testFailed {
            iconText = "\(icon) Multiple Jobs Are Now Failing"
            
        } else {
            iconText = "\(icon) Multiple Jobs having issues"
        }
        
        var message = ""
        
        for jobName in jobNames {
            message += "\(jobName)\n"
        }
        
        self.showNotification(title: iconText, message: message)
 
    }

}
