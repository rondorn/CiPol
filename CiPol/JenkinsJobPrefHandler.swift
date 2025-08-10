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
    var lastRunStatus = String()
    var status = String()
    var serverRecord = String()
    var lastPolled = String()
    var monitoring = Bool()
    var multiAlert = true
    var lastTested = String()
    var lastTestedDiff = Double()
    
    init(){

    }
    
    func setLastTestedDiff(lastTestedDiff: String){
        
        var lastTestedDiffValue = Double()
        
        print ("lastTestedDiff = \(lastTestedDiff)")
        
        lastTestedDiffValue = lastTestedDiff.toDouble() ?? 0
        
        print ("Setting lastTestedDiff to \(lastTestedDiffValue)")
        self.lastTestedDiff = lastTestedDiffValue
    }
    
    func getLastTestedDiff()->Double{
        return self.lastTestedDiff
    }
    
    func setLastTested(lastTested: String){
        self.lastTested = lastTested
    }
    func getLastTested()->String{
        return self.lastTested
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

    func setLastRunStatus(lastRunStatus: String){
        self.lastRunStatus = lastRunStatus
    }
    func getLastRunStatus()->String{
        return self.lastRunStatus
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
    
    func setMultiAlert(multiAlert: Bool){
        self.multiAlert = multiAlert
    }
    func getMultiAlert()->Bool{
        return self.multiAlert
    }
    
    //lastTestedDiff
    func getBasicArrayData()->[String:String]{
        
        var basicArray = [String:String]()
        basicArray["jobName"] = self.getJobName()
        basicArray["lastJobStatus"] = self.getLastJobStatus()
        basicArray["lastRunStatus"] = self.getLastRunStatus()
        basicArray["serverRecord"] = self.getServerRecord()
        basicArray["status"] = self.getStatus()
        basicArray["lastPolled"] = self.getLastPolled()
        basicArray["monitoring"] = String(self.getMonitoring())
        basicArray["multiAlert"] = String(self.getMultiAlert())
        basicArray["lastTested"] = self.getLastTested()
        basicArray["lastTestedDiff"] = String(self.getLastTestedDiff())
        
        return basicArray
    }
    
    func setFromBasicArrayDaya(basicArray: [String:String]){
        
        self.setJobName(jobName: basicArray["jobName"]!)
        self.setLastJobStatus(lastJobStatus: basicArray["lastJobStatus"]!)
        self.setServerRecord(serverRecord: basicArray["serverRecord"]!)
        self.setStatus(status: basicArray["status"]!)
        self.setLastPolled(lastPolled: basicArray["lastPolled"] ?? "")
        self.setLastTested(lastTested: basicArray["lastTested"] ?? "")
        self.setLastTestedDiff(lastTestedDiff: basicArray["lastTestedDiff"] ?? "0")

        self.setMonitoring(monitoring: Bool(basicArray["monitoring"] ?? "true") ?? true)
        self.setMultiAlert(multiAlert: Bool(basicArray["multiAlert"] ?? "true") ?? true)
        
    }
}

extension String {
    func toDouble() -> Double? {
        let numberIn = self
        let numberOut = NumberFormatter().number(from: numberIn)?.doubleValue
        
        print ("numberIn = \(numberIn) numberOut = \(numberOut ?? 0)")
        return numberOut?.rounded()
    }
}
