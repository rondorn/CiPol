//
//  JenkinsCommincationHandler.swift
//  CI-Monitor
//
//  Created by Ron Dorn on 2/7/21.
//

import Foundation

class JenkinsCommuncationHandler {
    
    var jenkinsOutput = [String: Any]()
    var testData = ""
    
    init(){
        
    }
    
    func updateAllJobs(preferences: PrefHandler){
        
        let jobList = preferences.getListOfJobs();
        
        for jobName in jobList {
            
            print ("Updating data for job \(jobName)")
            let jobData = preferences.getJobDetails(jobName: jobName)
            let status = getJobResults(preferences: preferences, jobData: jobData)
            
            jobData.setLastJobStatus(lastJobStatus: status["lastJobStatus"]!)
            jobData.setStatus(status: status["status"]!)
            jobData.setLastTested(lastTested: status["timeDiffString"] ?? "")
            jobData.setLastTestedDiff(lastTestedDiff: status["timeDiffDouble"] ?? "0")
            if (status["lastPolled"]?.isEmpty == false){
                jobData.setLastPolled(lastPolled:status["lastPolled"]!)
            }
            preferences.setJenkinsJobData(jobName: jobName, jobData: jobData)
            preferences.savePreferences()
            
        }
    }
    
    func validateJobCommunication (preferences: PrefHandler, jobData: JenkinsJobPrefHandler)->Bool {
        
        //returns pass/true fail/false
        var passed = true
        
        let status = getJobResults(preferences: preferences, jobData: jobData)
        
        print ("New Job Testing Status is \(status)")
        if (status["pollingStatus"] == nil){
            passed = false
        
        } else if status["pollingStatus"] == "missing lastSuccessfulBuild" {
            passed = false
        }
        
        return passed;
    }
    
    func validateServerCommunication(userName: String, password: String, urlString: String)->Bool {
        
        
        var passed = true
        
        let response = self.makeHttpCall(userName: userName, password: password, urlString: urlString)
        
        print ("http validation response is \(response)")
        
        if (response["httpStatus"] != nil) {
            if (response["httpStatus"] as! String != "Recieved http error 200"){
                passed = false
            }
        }
        
        return passed
    }
    
    
    func getJobResults(preferences: PrefHandler, jobData: JenkinsJobPrefHandler)->[String:String]{
        

        let serverName = jobData.getServerRecord()
        let jobName = jobData.getJobName()
        
        let serverData = preferences.getServerDetails(serverName: serverName)
        
        let serverUrl = serverData.getServerUrl()
        let userName = serverData.getUserName()
        let userPassword = serverData.getUserPassword(severName: serverName)
        
        var jenkinsUrl = String()
         
        if (jobName.contains("/job/")){
            jenkinsUrl = serverUrl + jobName + "/api/json"
        } else {
            jenkinsUrl = serverUrl + "/job/" + jobName + "/api/json"
        }
            
        
        print ("jenkinsUrl is \(jenkinsUrl)")
        let rawData = self.makeHttpCall(userName: userName, password: userPassword, urlString: jenkinsUrl)
        let status = self.buildPassed(rawData: rawData, preferences: preferences, jobName: jobName)
        
        return status
        
    }

    func makeHttpCall(userName: String, password: String, urlString: String)->[String:Any]{
        
        jenkinsOutput = [String: Any]()
        testData = ""
        
        print ("Json Output userName is \(userName)")
        print ("Json Output password is \(password)")
        
        
        var authString = ""
        
        if (userName.isEmpty == false){
            let userPasswordData = "\(userName):\(password)".data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            authString = "Basic \(base64EncodedCredential)"
            print ("Json Output userName authString is \(authString)")
        }
        
        let Url = Utilties.cleanUpURL(url: urlString)
        
        print ("Json Output urlString is \(Url)")
        let serviceUrl = URL(string: Url)
        var request = URLRequest(url: serviceUrl!)

        if (userName.isEmpty == false){
            request.httpMethod = "POST"
            request.setValue(authString, forHTTPHeaderField: "Authorization")
        }
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = Utilties.httpTimeoutValue
        
        var httpResponse = 0
        let semaphore = DispatchSemaphore(value: 0)  //1. create a counting semaphore

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let fullHttpResponse = response as? HTTPURLResponse {
                httpResponse = fullHttpResponse.statusCode
            }
            
            if (httpResponse != 200){
                self.jenkinsOutput["httpStatus"] = "Recieved http error \(httpResponse)"
            }
            
            //print("Json Output error is \(response) - \(error)")
            if let response = response {
                print("Json Output = response \(response)")
            }
            if let data = data {
                do {
                    print("Json Output " + String(data: data, encoding: .utf8)!)
                    print("Json Output data = \(data)")
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    self.jenkinsOutput = json as! [String : Any]
                } catch {
                    print("Json Output error = \(error)")
                }
            }
            semaphore.signal()  //3. count it up
        }.resume()
        
        
        semaphore.wait()  //2. wait for finished counting
        
        if self.testData.isEmpty == false {
            do {
                let json = try JSONSerialization.jsonObject(with: self.testData.data(using: .utf8)!, options: [])
                //print("Json Output json = \(json)")
                self.jenkinsOutput = json as! [String : Any]
            } catch {
                print("Json Output error = \(error)")
            }
        }
        
        print("https error = \(httpResponse)")
        print("returned Json Output json = \(self.jenkinsOutput)")
        return self.jenkinsOutput
    }
    
    func buildPassed(rawData: [String : Any], preferences: PrefHandler, jobName: String) -> [String:String] {
            
        var status = [String:String]()
        var lastCompletedBuildNumber = 0
        var lastBuildNumber = 0
        
        status["lastJobStatus"] = Utilties.testFailed
        status["status"] = Utilties.testInProgressStatus
        status["pollingStatus"] = "ok";
        
        if rawData.keys.contains("color"){
            let testColor = rawData["color"] as! String
            
            if (testColor.contains("blue")){
                status["lastJobStatus"] = Utilties.testPassed
            } else if (testColor.contains("red")){
                status["lastJobStatus"] = Utilties.testFailed
            } else {
                status["lastJobStatus"] = "Unknown"
            }
            status["lastPolled"] = Utilties.getTodayString()
            
        } else {
            status["lastJobStatus"] = Utilties.testErrorPolling
            status["status"] = Utilties.testErrorPolling
            status["pollingStatus"] = Utilties.testErrorPolling
            status["lastPolled"] = ""
        }
        
        let placeHolder = [String:Any]();
        
        if rawData.keys.contains("lastCompletedBuild"){
            let lastBuildData = rawData["lastCompletedBuild"] as? [String:Any] ?? placeHolder
            if lastBuildData.keys.contains("number"){
                lastCompletedBuildNumber = lastBuildData["number"] as! Int
                
                var lastRun = UInt64(getLastTestedData(preferences: preferences, jobName: jobName, jobNumber: lastCompletedBuildNumber)) ?? 0
            
                let localTime = NSDate().timeIntervalSince1970
                
                lastRun = (lastRun/1000)
                print ("lastRunTime = lastRun \(jobName) = \(lastRun)")
                print ("lastRunTime = localTime \(jobName) = \(localTime)")
                    
                let timeDiff:UInt64 = UInt64(localTime) - lastRun

                print ("lastRunTime = timeDiff \(jobName) = \(timeDiff)")
                
                let dateComponentsFormatter = DateComponentsFormatter()
                dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
                dateComponentsFormatter.maximumUnitCount = 1
                dateComponentsFormatter.unitsStyle = .full
                
                status["timeDiffString"] = dateComponentsFormatter.string(from: Date(), to: Date(timeIntervalSinceNow: TimeInterval(timeDiff)))  // "1 month"
                //print ("Convert timeDiff \(timeDiff) to be \(status["timeDiffString"])")
                
                status["timeDiffDouble"] = String(timeDiff)
            }
            
            
            
        } else {
            status["lastBuild"] = "missing lastBuild";
            print ("lastBuild data is missing")
        }
        
        if rawData.keys.contains("lastBuild") {
            let lastBuildData = rawData["lastBuild"] as? [String:Any] ?? placeHolder
            if lastBuildData.keys.contains("number"){
                lastBuildNumber = lastBuildData["number"] as! Int
            }
        } else {
            print ("lastBuild data is missing")
        }
        
        print ("lastCompletedBuildNumber = \(lastCompletedBuildNumber) lastBuildNumber = \(lastBuildNumber)")
        if (lastCompletedBuildNumber != 0 && lastBuildNumber != 0){
            if (lastCompletedBuildNumber == lastBuildNumber){
                status["status"] = Utilties.tesNotRunningStatus
            } else {
                status["status"] = Utilties.testInProgressStatus
            }
        } else {
            status["status"] = Utilties.tesNotRunningStatus
        }
        
        return status
    }
    
    func setTestData(testData: String){
        
        self.testData = testData
    
    }

    func getLastTestedData(preferences: PrefHandler, jobName: String, jobNumber: Int)->String{
        
        let jobData = preferences.getJobDetails(jobName: jobName)
        let serverName = jobData.getServerRecord()
        let jobName = jobData.getJobName()
        
        let serverData = preferences.getServerDetails(serverName: serverName)
        
        let serverUrl = serverData.getServerUrl()
        let userName = serverData.getUserName()
        let userPassword = serverData.getUserPassword(severName: serverName)
        
        var jenkinsUrl = String()
         
        if (jobName.contains("/job/")){
            jenkinsUrl = serverUrl + jobName + "/" + String(jobNumber) + "/api/json"
        } else {
            jenkinsUrl = serverUrl + "/job/" + jobName +  "/" + String(jobNumber) + "/api/json"
        }
        
        let rawData = makeHttpCall(userName: userName, password: userPassword, urlString: jenkinsUrl)
        
        var timestamp = Int()
        for dataKeys in rawData {
            
            if dataKeys.key == "timestamp"{
                timestamp = dataKeys.value as! Int
            }
        }

        let timeString = String(timestamp)
        
        return timeString
    }
    
}
