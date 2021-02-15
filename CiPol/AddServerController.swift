//
//  AddServerController.swift
//  CiPol
//
//  Created by Ron Dorn on 2/11/21.
//

import Foundation
import Cocoa

class AddServerController: NSViewController {

    let prefHandler = PrefHandler()
    @IBOutlet weak var serverNameField: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        prefHandler.loadPreferences();
        
        if (Utilties.activeServerRecord.isEmpty == false){
            loadExistingData(serverName: Utilties.activeServerRecord)
        }
    
    }
    
    
    func loadExistingData(serverName: String){
        
        let serverDeatils = prefHandler.getServerDetails(serverName: serverName)
        serverNameField.stringValue = serverDeatils.getServerName()
        urlField.stringValue = serverDeatils.getServerUrl()
        userNameField.stringValue = serverDeatils.getUserName()
        passwordField.stringValue = serverDeatils.getUserPassword(severName: serverName)
        
    }
    
    
    func renameServer(newName: String, oldName: String){
            
        let jobNames = prefHandler.getAllJobForServer(serverRecord: oldName)
        
        for jobName in jobNames {
            
            let jobData = prefHandler.getJobDetails(jobName: jobName)
            jobData.setServerRecord(serverRecord: newName)
        }
        
        prefHandler.removeJenkinsServer(serverName: oldName)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let serverName = serverNameField.stringValue
        var url = urlField.stringValue
        let userName = userNameField.stringValue
        let password = passwordField.stringValue
        
        let newServer = JenkinsServerPrefHandler()
        
        if url.contains("https://") == false {
            url = "http://" + url
        }
        
        if Utilties.activeServerRecord.isEmpty == false{
            if (serverName != Utilties.activeServerRecord){
                renameServer(newName: serverName, oldName:Utilties.activeServerRecord)
            }
        }
        
        newServer.setUserName(userName: userName)
        newServer.setServerUrl(serverUrl: url)
        newServer.setServerName(serverName: serverName)
        newServer.setUserPassword(userPassword: password, severName: serverName)
                
        let testHandler = JenkinsCommuncationHandler();
        
        let status = testHandler.validateServerCommunication(userName:userName, password: password, urlString: url)
        
        if status == true {
            prefHandler.setJenkinsServerData(serverName: serverName, serverData: newServer)
            prefHandler.savePreferences()
            prefHandler.loadPreferences()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadServer"), object: nil)
            self.dismiss(self)
        } else {
            _ = Toast.displayMesssage(title: "Alert", message: "Encountered error when attempting to communicate with server")
        }
    
    }
    
}
