//
//  JenkinsServerHandler.swift
//  CI-Monitor
//
//  Created by Ron Dorn on 2/6/21.
//

import Foundation

class JenkinsServerPrefHandler {

    var serverUrl = String()
    var serverName = String()
    var userName = String()
    
    init(){

    }
 
    func setServerName(serverName: String){
        self.serverName = serverName
    }
    func getServerName()->String{
        return self.serverName
    }
    
    func setServerUrl(serverUrl: String){
        self.serverUrl = serverUrl
    }
    func getServerUrl()->String{
        return self.serverUrl
    }
    
    func setUserName(userName: String){
        self.userName = userName
    }
    func getUserName()->String{
        return self.userName
    }
    
    func setUserPassword(userPassword: String, severName: String){
        
        let passStore = PasswordStorage()
        passStore.setPassword(serverName: severName, password: userPassword)

    }
    func getUserPassword(severName: String)->String{
        
        let passStore = PasswordStorage()
        let password = passStore.getPassword(serverName: severName)
        
        return password
    }
    
    func getBasicArrayData()->[String:String]{
        
        var basicArray = [String:String]()
        basicArray["serverName"] = self.getServerName()
        basicArray["url"] = self.getServerUrl()
        basicArray["userName"] = self.getUserName()
        
        return basicArray
    }
    
    func setFromBasicArrayData(basicArray: [String:String]){
        
        self.setServerName(serverName: basicArray["serverName"]!)
        self.setServerUrl(serverUrl: basicArray["url"]!)
        self.setUserName(userName: basicArray["userName"]!)
        
    }
}
