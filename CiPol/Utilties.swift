//
//  Utilties.swift
//  CiPol
//
//  Created by Ron Dorn on 2/10/21.
//

import Foundation

class Utilties {
    
    static let testPassed = "Passing"
    static let testFailed = "Failing"
    static let testInProgressStatus = "In Progress"
    static let tesNotRunningStatus = "Idle"
    static let testErrorPolling = "Error in polling"
    static let testNotPolled = "Not Polled"
    static let testUnknown = "Unknown"
    
    static var backgroundWaitInSeconds :UInt32 = 0
    static var activeServerRecord = ""
    static var activeJobRecord = ""
    
    static func cleanUpURL(url: String)->String {
        
        var cleanUrl = String(format: url)
        cleanUrl = cleanUrl.replacingOccurrences(of: " ", with: "%20")
        
        return cleanUrl
    }
    
    static func getBackgroundWaitInSeconds()->UInt32{
        
        let prefHandler = PrefHandler()
        prefHandler.loadPreferences()
        let pollingIntervalInMIn = UInt32(prefHandler.getPollingInterval())
        
        self.backgroundWaitInSeconds = pollingIntervalInMIn * 60
        
        return self.backgroundWaitInSeconds
    }
    
    static func getPassFailIcon(status: String)->String{
        
        var statusIcon = ""
        
        print ("Recieved a status of \(status)")
        if status == Utilties.testPassed {
            statusIcon = "🟢"
            
        } else if status == Utilties.testFailed {
            statusIcon = "🔴"

        } else {
            statusIcon = "⚪️"
        }
        
        return statusIcon
    }
    
    static func getMonitoringIcon(status: String)->String{
        
        var statusIcon = ""
        
        if status == "true" {
            statusIcon = "✅"
            
        } else  {
            statusIcon = "⬜️"

        }
        
        return statusIcon
    }
    
    static func getTodayString() -> String{
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        
        dateFormatter.dateFormat = "hh:mm a MM-dd "
        let today_string = dateFormatter.string(from: date)
        
        return today_string

   }

}
