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
    static var alertTypes = [String:String](); // Track if alert is "stateChange" or "multiAlert"
    static var previousJobStatuses = [String:String](); // Track previous job run statuses (Idle/In Progress)
    static var jobsInProgress = [String:Bool](); // Track which jobs were recently in progress
    
    init(){

    }
    
    func backgroundRunner (){
            
        while(true){
            let sleepFor = Utilties.getBackgroundWaitInSeconds()
            print ("BackgroundTesting -  sleeping for \(sleepFor)")
            sleep(sleepFor)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        }
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
    
    func runTests(prefHandler: PrefHandler){
        
        //exit if already running tests
        if (Utilties.runningRefresh == true && Utilties.firstLaunch == false){
            return
        }
        
        var oldJobStatus = [String:String]();
        var newJobStatus = [String:String]();
        
        if (Utilties.firstLaunch == false){
            let sleepFor = Utilties.getBackgroundWaitInSeconds()
            print ("BackgroundTesting -  sleeping for \(sleepFor)")
            oldJobStatus = gatherJobStatuses(prefHandler: prefHandler)
            sleep(sleepFor)
        } else {
            Utilties.firstLaunch = false
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
        sendMultiAlerts(prefHandler: prefHandler, newJobStatus: newJobStatus)
                
        print ("BackgroundTesting - Done")
 
    }

    func sendAlerts(oldJobStatus: [String:String], newJobStatus: [String:String]){
        
        for jobName in oldJobStatus {
            let oldStatus = oldJobStatus[jobName.key]
            let newStatus = newJobStatus[jobName.key]
            
            print ("BackgroundTesting - compare \(jobName.key) \(oldStatus ?? "nil") \(newStatus ?? "nil")")
            
            if (oldStatus != newStatus){
                print ("BackgroundTesting - sensing alert for \(jobName.key)")
                BackgroundTesting.alertData[jobName.key] = newStatus
                BackgroundTesting.alertTypes[jobName.key] = "stateChange"
            }
        }
    }
    
    func sendMultiAlerts(prefHandler: PrefHandler, newJobStatus: [String:String]){
        
        for jobName in newJobStatus {
            let jobDetails = prefHandler.getJobDetails(jobName: jobName.key)
            let newFailStatus = newJobStatus[jobName.key] // This is the lastJobStatus (Passing/Failing)
            let newRunStatus = jobDetails.getStatus() // This is the current run status (Idle/In Progress)
            let previousRunStatus = BackgroundTesting.previousJobStatuses[jobName.key]
            
            print ("BackgroundTesting - checking multi alert for \(jobName.key)")
            print ("  - failStatus: \(newFailStatus ?? "nil"), runStatus: \(newRunStatus), previousRunStatus: \(previousRunStatus ?? "nil")")
            print ("  - multiAlert enabled: \(jobDetails.getMultiAlert())")
            
            // Track status transitions
            BackgroundTesting.previousJobStatuses[jobName.key] = newRunStatus
            
            // Check if job went In Progress -> Idle (completed a test cycle)
            let completedTestCycle = (previousRunStatus == Utilties.testInProgressStatus && newRunStatus == Utilties.tesNotRunningStatus)
            
            if completedTestCycle {
                print ("  - Job \(jobName.key) completed test cycle (In Progress -> Idle)")
                BackgroundTesting.jobsInProgress[jobName.key] = false
            }
            
            // Track if job is currently in progress
            if newRunStatus == Utilties.testInProgressStatus {
                BackgroundTesting.jobsInProgress[jobName.key] = true
            }
            
            // Send multi alert if:
            // 1. Multi alert is enabled
            // 2. Job is currently failing
            // 3. Job just completed a test cycle (In Progress -> Idle)
            // 4. No state change alert already exists for this job
            if (jobDetails.getMultiAlert() == true && 
                newFailStatus == Utilties.testFailed && 
                completedTestCycle &&
                BackgroundTesting.alertTypes[jobName.key] == nil) {
                
                print ("BackgroundTesting - sensing multi alert for \(jobName.key) (still failing after test cycle)")
                BackgroundTesting.alertData[jobName.key] = newFailStatus
                BackgroundTesting.alertTypes[jobName.key] = "multiAlert"
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
