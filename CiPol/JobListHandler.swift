//
//  getJobListFromUrl.swift
//  CiPol
//
//  Created by Ron Dorn on 2/13/21.
//

import Foundation

let jenkinsCommuncation = JenkinsCommuncationHandler();

class JobListHandler {
    
    init(){
        
    }
    
    
    func getJobList(prefHandler: PrefHandler, serverName: String, appendedJobName: String) -> [String]{
         
        var jobList = [String]()
        
        //return empty if server ois empty
        if (serverName.isEmpty == true){
            return jobList
        }
        

        
        let serverData = prefHandler.getServerDetails(serverName: serverName)
        let currentJobList = prefHandler.getListOfJobs()
        
        var serverUrl = ""
        
        if (appendedJobName.isEmpty == false){
            serverUrl = serverData.getServerUrl() + appendedJobName +  "/api/json"
        } else {
            serverUrl = serverData.getServerUrl() + "/api/json"
        }
        
        print ("Using final job url of \(serverUrl)")
        
        let userName = serverData.getUserName()
        let userPassword = serverData.getUserPassword(severName: serverName)
        
        let jenkinsHandler = JenkinsCommuncationHandler();
        
        print ("Trying to load server URL of \(serverUrl) ")
        let jsonData = jenkinsHandler.makeHttpCall(userName: userName, password: userPassword, urlString: serverUrl)
        
        if (jsonData["jobs"] != nil){
            let jobData = jsonData["jobs"] as! Array<[String:String]>
            for job in jobData {
                
                var addJob = true
                let color = job["color"] ?? ""
                var jobName = job["name"] ?? ""
                
                if (color == "blue" || color == "red") {
                    if currentJobList.contains(jobName){
                        let jobDetails = prefHandler.getJobDetails(jobName: jobName)
                        if serverName == jobDetails.getServerRecord() {
                            addJob = false
                        }
                    }
                } else if color == ""{
                    jobName = "/job/" + jobName
                    
                } else {
                    addJob = false
                }
                if (addJob == true){
                    jobList.append(jobName)
                }
            }
            
            jobList = jobList.sorted()
        }
        return jobList
    }
}
