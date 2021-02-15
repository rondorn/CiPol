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
            jobData.setLastPolled(lastPolled:status["lastPolled"]!)
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
        let status = self.buildPassed(rawData: rawData)
        
        return status
        
    }

    func makeHttpCall(userName: String, password: String, urlString: String)->[String:Any]{
        
        print ("Json Output userName is \(userName)")
        print ("Json Output password is \(password)")
        
        
        let cleanUrlString = urlString.replacingOccurrences(of: " ", with: "%20")
        
        print ("Json Output urlString is \(cleanUrlString)")
        var authString = ""
        
        if (userName.isEmpty == false){
            let userPasswordData = "\(userName):\(password)".data(using: .utf8)
            let base64EncodedCredential = userPasswordData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            authString = "Basic \(base64EncodedCredential)"
            print ("Json Output userName authString is \(authString)")
        }
        
        let Url = String(format: cleanUrlString)
        let serviceUrl = URL(string: Url)
        var request = URLRequest(url: serviceUrl!)

        if (userName.isEmpty == false){
            request.httpMethod = "POST"
            request.setValue(authString, forHTTPHeaderField: "Authorization")
        }
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        
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
    
    func buildPassed(rawData: [String : Any]) -> [String:String] {
            
        var status = [String:String]()
        var lastCompletedBuildNumber = 0
        var lastBuildNumber = 0
        
        status["lastJobStatus"] = Utilties.testFailed
        status["status"] = Utilties.testInProgressStatus
        status["lastPolled"] = Utilties.getTodayString()
        status["pollingStatus"] = "ok";
        
        if rawData.keys.contains("color"){
            let testColor = rawData["color"] as! String
            
            if (testColor.contains("blue")){
                status["lastJobStatus"] = Utilties.testPassed
            } else if (testColor == "red"){
                status["lastJobStatus"] = Utilties.testFailed
            } else {
                status["lastJobStatus"] = "Unknown"
            }
            
        }
        
        if rawData.keys.contains("lastCompletedBuild"){
            print ("lastCompletedBuild data is \(rawData["lastBuild"] ?? "Nothing")")
            let lastBuildData = rawData["lastCompletedBuild"] as! [String:Any]
            if lastBuildData.keys.contains("number"){
                lastCompletedBuildNumber = lastBuildData["number"] as! Int
            }
            
        } else {
            status["lastBuild"] = "missing lastBuild";
            print ("lastBuild data is missing")
        }
        
        if rawData.keys.contains("lastBuild"){
            let lastBuildData = rawData["lastBuild"] as! [String:Any]
            if lastBuildData.keys.contains("number"){
                lastBuildNumber = lastBuildData["number"] as! Int
            }
        } else {
            print ("lastBuild data is missing")
        }
        
        
        if (lastCompletedBuildNumber != 0 && lastBuildNumber != 0){
            if (lastCompletedBuildNumber == lastBuildNumber){
                status["status"] = Utilties.tesNotRunningStatus
            }
        }
        
        return status
    }
    
    func setTestData(testData: String){
        
        self.testData = testData
    
    }

}

