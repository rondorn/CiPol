//
//  BackgroundTesting.swift
//  CiPol
//
//  Created by Ron Dorn on 2/11/21.
//

import Foundation


class BackgroundTesting {
    
    let notificationHandler = NotificationHandler()
    
    static var alertData = [String:String]();
    
    init(){

    }

    func runNewTests(prefHandler: PrefHandler, firstLaunch: Bool){
        
        print ("Entered runNewTests")
        let jobs = prefHandler.getListOfJobs()
        let jenkinsHandler = JenkinsCommuncationHandler()
        
        for jobName in jobs {
            
            let jobData = prefHandler.getJobDetails(jobName: jobName)
            
            print ("runNewTests lastPolled for job \(jobName) equals \(jobData.getLastPolled())")
            if jobData.getLastPolled() == Utilties.testNotPolled {
                
                print ("runNewTests updated job \(jobName)")
                let status = jenkinsHandler.getJobResults(preferences: prefHandler, jobData: jobData)
                jobData.setLastJobStatus(lastJobStatus: status["lastJobStatus"]!)
                jobData.setStatus(status: status["status"]!)
                jobData.setLastTested(lastTested: status["timeDiffString"] ?? "")
                jobData.setLastTestedDiff(lastTestedDiff: status["timeDiffDouble"] ?? "0")
                if (status["lastPolled"]?.isEmpty == false){
                    jobData.setLastPolled(lastPolled:status["lastPolled"]!)
                }
                prefHandler.setJenkinsJobData(jobName: jobName, jobData: jobData)
                
            }
        }
        
        prefHandler.savePreferences()
    }
    
    func runTests(prefHandler: PrefHandler, firstLaunch: Bool){
        
        var oldJobStatus = [String:String]();
        var newJobStatus = [String:String]();
        
        if (firstLaunch == false){
            let sleepFor = Utilties.getBackgroundWaitInSeconds()
            print ("BackgroundTesting -  sleeping for \(sleepFor)")
            oldJobStatus = gatherJobStatuses(prefHandler: prefHandler)
            sleep(sleepFor)
        }
        
        prefHandler.loadPreferences()
        oldJobStatus = gatherJobStatuses(prefHandler: prefHandler)
        
        print ("BackgroundTesting - Done sleeping")
        let jenkinsHandler = JenkinsCommuncationHandler()
        jenkinsHandler.updateAllJobs(preferences: prefHandler)
        
        prefHandler.savePreferences()
        prefHandler.loadPreferences()
        
        newJobStatus = gatherJobStatuses(prefHandler: prefHandler)
        
        sendAlerts(oldJobStatus: oldJobStatus, newJobStatus: newJobStatus)
                
        print ("BackgroundTesting - Done")
 
    }

    func sendAlerts(oldJobStatus: [String:String], newJobStatus: [String:String]){
        
        for jobName in oldJobStatus {
            let oldStatus = oldJobStatus[jobName.key]
            let newStatus = newJobStatus[jobName.key]
            
            //print ("BackgroundTesting - compare \(jobName.key) \(oldStatus) \(newStatus)")
            if (oldStatus != newStatus){
                print ("BackgroundTesting - sensing alert for \(jobName.key)")
                BackgroundTesting.alertData[jobName.key] = newStatus
            }
        }
    }
    
    func gatherJobStatuses(prefHandler: PrefHandler)->[String:String]{
        
        var oldJobStatus = [String:String]();
        
        for jobName in prefHandler.getListOfJobs() {
            let jobData = prefHandler.getJobDetails(jobName: jobName)
            let jobStatus = jobData.getLastJobStatus()
            
            oldJobStatus[jobName] = jobStatus
        }
        return oldJobStatus
    }
}
