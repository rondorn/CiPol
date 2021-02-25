//
//  PrefHandler.swift
//  CI-Monitor
//
//  Created by Ron Dorn on 2/6/21.
//

import Foundation

class PrefHandler {
    
    var jenkinsServerData = [String: JenkinsServerPrefHandler]()
    var jenkinsJobs = [String: JenkinsJobPrefHandler]()
    var pollingInterval : Int = Int()
    
    var sortingField = String()
    var sortingDirection = Bool()
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var preferenceFileLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    init(){
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            preferenceFileLocation = documentURL.appendingPathComponent("ci-monitor.json.tst")
        } else {
            preferenceFileLocation = documentURL.appendingPathComponent("ci-monitor.json")
        }
        
        print ("Writing pref file to \(preferenceFileLocation)")
    }
    
    func setSortingField(value: String){
        self.sortingField = value
    }
    func getSortingField()->String{
        return self.sortingField
    }

    func setSortingDirection(value: Bool){
        self.sortingDirection = value
    }
    func getSortingDirection()->Bool{
        return self.sortingDirection
    }
    
    func setJenkinsServerData(serverName:String, serverData: JenkinsServerPrefHandler){
        self.jenkinsServerData[serverName] = serverData
    }
    
    func setJenkinsJobData(jobName: String, jobData: JenkinsJobPrefHandler){
        self.jenkinsJobs[jobName] = jobData
    }
    
    func removeJenkinsJob(jobName: String){
        self.jenkinsJobs.removeValue(forKey: jobName)
        self.savePreferences()
        self.loadPreferences()
    }
    
    func getJenkinsJobData()->[String: JenkinsJobPrefHandler]{
        return self.jenkinsJobs
    }
    
    func setPollingInterval(interval: Int){
        self.pollingInterval = interval
    }
        
    func getServerDetails(serverName: String)-> JenkinsServerPrefHandler{
        print ("Looking up serverName for \(serverName)")
        return self.jenkinsServerData[serverName] ?? JenkinsServerPrefHandler()
    }
 
    func removeJenkinsServer(serverName: String){
        self.jenkinsServerData.removeValue(forKey: serverName)
        self.savePreferences()
        self.loadPreferences()
    }
    
    func getAllJobForServer(serverRecord: String)->[String]{
        
        var listOfJobs = [String]()
        
        for jobName in self.jenkinsJobs{
            let jobDetails = self.getJobDetails(jobName: jobName.key)
            if jobDetails.getServerRecord() == serverRecord {
                listOfJobs.append(jobName.key)
            }
        }
        
        return listOfJobs
    }
    
    func getListOfServers() -> [String]{
        var listOfServers = [String]()
        
        for serverName in self.jenkinsServerData{
            listOfServers.append(serverName.key)
        }
        
        listOfServers = listOfServers.sorted()
        
        return listOfServers
    }
    
    func getListOfJobs() -> [String]{
        var listOfJobs = [String]()
        
        for jobName in self.jenkinsJobs{
            listOfJobs.append(jobName.key)
        }
        
        listOfJobs = listOfJobs.sorted()
        
        return listOfJobs
    }
    
    func getJobDetails(jobName: String)-> JenkinsJobPrefHandler{
        
        return self.jenkinsJobs[jobName] ?? JenkinsJobPrefHandler()
    }
    
    func getPollingInterval()->Int{
        
        if (self.pollingInterval == 0){
            self.pollingInterval = 10
        }
        return self.pollingInterval
    }
    
    
    func savePreferences(){
        
        var combinedPrefs = [String:[String:[String:String]]]()
        
        combinedPrefs["jenkinsServerData"] = [String:[String:String]]()
        combinedPrefs["jenkinsJobs"] = [String:[String:String]]()
        
        combinedPrefs["pollingInterval"] = [String:[String:String]]()
        combinedPrefs["pollingInterval"]!["pollingInterval"] = [String:String]();
        combinedPrefs["pollingInterval"]!["pollingInterval"]!["pollingInterval"] = String(self.getPollingInterval())

        combinedPrefs["sortingField"] = [String:[String:String]]()
        combinedPrefs["sortingField"]!["sortingField"] = [String:String]();
        combinedPrefs["sortingField"]!["sortingField"]!["sortingField"] = self.getSortingField()
        
        combinedPrefs["sortingDirection"] = [String:[String:String]]()
        combinedPrefs["sortingDirection"]!["sortingDirection"] = [String:String]();
        combinedPrefs["sortingDirection"]!["sortingDirection"]!["sortingDirection"] = String(self.getSortingDirection())
        
        print ("jenkinsServerData, data equals \(self.jenkinsServerData)")
        for serverName in self.jenkinsServerData{
            var variableValues = [String:String]();
            let serverNameValue = serverName.key as String
            let serverRecord = self.jenkinsServerData[serverNameValue]! as JenkinsServerPrefHandler
            
            variableValues = serverRecord.getBasicArrayData()
            
            combinedPrefs["jenkinsServerData"]![serverNameValue] = variableValues
        }
        
        for jobName in self.jenkinsJobs{
            print ("Working on job Name \(jobName)")
            var variableValues = [String:String]();
            let jobNameValue = jobName.key as String
            let jobRecord = self.jenkinsJobs[jobNameValue]! as JenkinsJobPrefHandler
            
            variableValues = jobRecord.getBasicArrayData()
            combinedPrefs["jenkinsJobs"]![jobNameValue] = variableValues
        }
        
        print ("Saving combined data of \(combinedPrefs)")
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: combinedPrefs, options: [.prettyPrinted])
            try data.write(to: preferenceFileLocation, options: [])
            print ("Saving combined data to \(preferenceFileLocation)")
        } catch {
            print(error)
        }
    }
    
    func loadPreferences(){
        
        self.jenkinsServerData = [String: JenkinsServerPrefHandler]()
        self.jenkinsJobs = [String: JenkinsJobPrefHandler]()
        
        var combinedPrefs = [String:[String:[String:String]]]()
        var encounteredError = false
        // Read data from .json file and transform data into an array
        do {
            let data = try Data(contentsOf: preferenceFileLocation, options: [])
            combinedPrefs = try (JSONSerialization.jsonObject(with: data, options: []) as? [String:[String:[String:String]]])!
            print(combinedPrefs)
        } catch {
            print("Could not load pref file due to \(error)")
            encounteredError = true
        }
        
        if (encounteredError == false){
            self.pollingInterval = Int(combinedPrefs["pollingInterval"]!["pollingInterval"]!["pollingInterval"]!) ?? 0
            self.sortingField = combinedPrefs["sortingField"]?["sortingField"]?["sortingField"] ?? ""
            self.sortingDirection = Bool(combinedPrefs["sortingDirection"]?["sortingDirection"]?["sortingDirection"] ?? "false") ?? false
            
            let serverData = combinedPrefs["jenkinsServerData"]!
            let jobData = combinedPrefs["jenkinsJobs"]!
            
            for serverName in serverData {
                
                let serverNameValue = serverName.key
                let serverHandle = JenkinsServerPrefHandler()
                var serverDataSet = [String:String]()
                
                serverDataSet = serverData[serverNameValue]!
                
                serverHandle.setFromBasicArrayData(basicArray: serverDataSet)
                
                self.setJenkinsServerData(serverName: serverNameValue, serverData: serverHandle)
            }
            
            for jobName in jobData {
                
                let jobNameValue = jobName.key
                let jobHandle = JenkinsJobPrefHandler()
                var jobDataSet = [String:String]()
                
                jobDataSet = jobData[jobNameValue]!
                
                jobHandle.setFromBasicArrayDaya(basicArray: jobDataSet)
                
                self.setJenkinsJobData(jobName: jobNameValue, jobData: jobHandle)
            }
        }
    }
    
}
