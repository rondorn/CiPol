//
//  JenkinsJobPrefHandler.swift
//  CI-Monitor
//
//  Created by Ron Dorn on 2/6/21.
//

import Foundation

class JenkinsJobPrefHandler {

    var jobName = String()
    var lastJobStatus = String()
    var status = String()
    var serverRecord = String()
    var lastPolled = String()
    var monitoring = Bool()
    
    init(){

    }
    
    func setJobName(jobName: String){
        self.jobName = jobName
    }
    func getJobName()->String{
        return self.jobName
    }
 
    func setStatus(status: String){
        self.status = status
    }
    func getStatus()->String{
        return self.status
    }
 
    func setLastPolled(lastPolled: String){
        self.lastPolled = lastPolled
    }
    func getLastPolled()->String{
        return self.lastPolled
    }
    
    func setLastJobStatus(lastJobStatus: String){
        self.lastJobStatus = lastJobStatus
    }
    func getLastJobStatus()->String{
        return self.lastJobStatus
    }
 
    func setServerRecord(serverRecord: String){
        self.serverRecord = serverRecord
    }
    func getServerRecord()->String{
        return self.serverRecord
    }
    
    func setMonitoring(monitoring: Bool){
        self.monitoring = monitoring
    }
    func getMonitoring()->Bool{
        return self.monitoring
    }
    
    func getBasicArrayData()->[String:String]{
        
        var basicArray = [String:String]()
        basicArray["jobName"] = self.getJobName()
        basicArray["lastJobStatus"] = self.getLastJobStatus()
        basicArray["serverRecord"] = self.getServerRecord()
        basicArray["status"] = self.getStatus()
        basicArray["lastPolled"] = self.getLastPolled()
        basicArray["monitoring"] = String(self.getMonitoring())
        return basicArray
    }
    
    func setFromBasicArrayDaya(basicArray: [String:String]){
        
        self.setJobName(jobName: basicArray["jobName"]!)
        self.setLastJobStatus(lastJobStatus: basicArray["lastJobStatus"]!)
        self.setServerRecord(serverRecord: basicArray["serverRecord"]!)
        self.setStatus(status: basicArray["status"]!)
        self.setLastPolled(lastPolled: basicArray["lastPolled"] ?? "")
        self.setMonitoring(monitoring: Bool(basicArray["monitoring"] ?? "true") ?? true)

    }
}

