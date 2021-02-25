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
    static var backgroundWaitInSeconds :UInt32 = 0
    static var activeServerRecord = ""
    
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
        
        /*
       let date = Date()
       let calender = Calendar.current
       let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

       let year = components.year
       let month = components.month
       let day = components.day
       let hour = components.hour
       let minute = components.minute

        let today_string = String(hour!)  + ":" + String(minute!) + ":" + " " + String(month!) + "-" + String(day!) + "-" + String(year!)
    
        */
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        let today_string = dateFormatter.string(from: date)
        
        return today_string

   }

}
