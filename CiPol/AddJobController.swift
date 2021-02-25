//
//  AddJobController.swift
//  CiPol
//
//  Created by Ron Dorn on 2/10/21.
//

import Foundation
import Cocoa

class AddJobController: NSViewController {
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var serverNamePopUp: NSPopUpButton!
    
    @IBOutlet weak var jobNamePopUp: NSPopUpButton!
    @IBOutlet weak var jobNamePopUp2: NSPopUpButton!
    @IBOutlet weak var jobNamePopUp3: NSPopUpButton!
    @IBOutlet weak var jobNamePopUp4: NSPopUpButton!
    
    let prefHandler = PrefHandler()
    var serverJobs = [String]()
    var selectedServerJob  = ""
    var finalJobName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefHandler.loadPreferences();
        serverJobs = prefHandler.getListOfServers();
        
        buildServerMenu()
    }
    
    func buildServerMenu(){
        
        serverNamePopUp.removeAllItems()
        jobNamePopUp2.isHidden = true
        jobNamePopUp3.isHidden = true
        jobNamePopUp4.isHidden = true
        
        serverNamePopUp.addItem(withTitle: "")
        serverJobs = serverJobs.sorted()
        selectedServerJob = ""
        
        for serverName in serverJobs {
            serverNamePopUp.addItem(withTitle: serverName)
        }
        
        buildJobsMenu(jobMenu: jobNamePopUp)
    }
    
    func buildJobsMenu(jobMenu: NSPopUpButton){
        
        jobMenu.removeAllItems()
        
        let jobLisHandler = JobListHandler()
        let jobNames = jobLisHandler.getJobList(prefHandler: prefHandler, serverName: selectedServerJob, appendedJobName: finalJobName)
        
        jobMenu.addItem(withTitle: "")
        if (selectedServerJob.isEmpty == false){
            for jobName in jobNames {
                jobMenu.addItem(withTitle: jobName)
            }
        }
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let newJob = JenkinsJobPrefHandler()
        let newJobName = finalJobName
        let serverName = serverNamePopUp.titleOfSelectedItem!
        
        print ("Using final job name of \(newJobName)")
        if (newJobName.isEmpty == false && serverName.isEmpty == false){
            print ("newJobName is \(newJobName) - serverName is \(serverName)")
            newJob.setJobName(jobName: newJobName)
            newJob.setServerRecord(serverRecord: serverName)
            newJob.setStatus(status: "Unknown")
            newJob.setLastPolled(lastPolled: "Not Polled")
            newJob.setLastJobStatus(lastJobStatus: "Unknown")
            newJob.setMonitoring(monitoring: true)
            
            let testHandler = JenkinsCommuncationHandler();
            let status = testHandler.validateJobCommunication(preferences: prefHandler, jobData: newJob)
            
            print ("New Job Testing Status is \(status)")
            
            if (status == true){
                prefHandler.setJenkinsJobData(jobName: newJobName, jobData: newJob)
                prefHandler.savePreferences()
                prefHandler.loadPreferences()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                
                self.dismiss(self)
            } else {
                _ = Toast.displayMesssage(title: "Alert", message: "Encountered error when attempting to communicate with server")
            }
        } else {
            _ = Toast.displayMesssage(title: "Alert", message: "Not all data provided")
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func serverPopUpAction(_ sender: Any) {
        
        finalJobName = ""
        
        selectedServerJob = serverNamePopUp.titleOfSelectedItem!
        finalJobName = ""
        jobNamePopUp2.isHidden = true
        jobNamePopUp3.isHidden = true
        jobNamePopUp4.isHidden = true
        
        buildJobsMenu(jobMenu: jobNamePopUp)
    }
    
    @IBAction func jobPopUpAction(_ sender: Any) {
        
        finalJobName = jobNamePopUp.titleOfSelectedItem!
        
        if (jobNamePopUp.titleOfSelectedItem?.contains("/job/") == true){
            finalJobName = jobNamePopUp.titleOfSelectedItem!
            jobNamePopUp2.isHidden = false
            buildJobsMenu(jobMenu: jobNamePopUp2)
        } else {
            jobNamePopUp2.isHidden = true
            jobNamePopUp3.isHidden = true
            jobNamePopUp4.isHidden = true
        }
    }

    @IBAction func jobPopUpAction2(_ sender: Any) {
        
        if (jobNamePopUp2.titleOfSelectedItem?.contains("/job/") == true){
            finalJobName = finalJobName + "/" + jobNamePopUp2.titleOfSelectedItem!
            jobNamePopUp3.isHidden = false
            buildJobsMenu(jobMenu: jobNamePopUp3)
        
        } else {
            finalJobName = finalJobName + "/job/" + jobNamePopUp2.titleOfSelectedItem!
            jobNamePopUp3.isHidden = true
            jobNamePopUp4.isHidden = true
        }
    }
    
    @IBAction func jobPopUpAction3(_ sender: Any) {
        
        if (jobNamePopUp3.titleOfSelectedItem?.contains("/job/") == true){
            finalJobName = finalJobName + "/" +  jobNamePopUp3.titleOfSelectedItem!
            jobNamePopUp4.isHidden = false
            buildJobsMenu(jobMenu: jobNamePopUp4)
        } else {
            finalJobName = finalJobName + "/job/" +  jobNamePopUp3.titleOfSelectedItem!
            jobNamePopUp4.isHidden = true
        }
        
    }
    
    @IBAction func jobPopUpAction4(_ sender: Any) {
        
        if (jobNamePopUp4.titleOfSelectedItem?.contains("/job/") == true){
            _ = Toast.displayMesssage(title: "Alert", message: "You have reached the maximum number of levels")
        } else {
            finalJobName = finalJobName + "/" +  jobNamePopUp4.titleOfSelectedItem!
        }
    }
    
    
}
