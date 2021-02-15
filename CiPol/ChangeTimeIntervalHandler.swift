//
//  AddServerController.swift
//  CiPol
//
//  Created by Ron Dorn on 2/11/21.
//

import Foundation
import Cocoa

class ChangeTimeIntervalHandler: NSViewController {

    let prefHandler = PrefHandler()
    @IBOutlet weak var pollingIntervalField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefHandler.loadPreferences();
        let interval = String(prefHandler.getPollingInterval())
        pollingIntervalField.stringValue = interval
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(self)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let interval = Int(pollingIntervalField.stringValue)
        prefHandler.setPollingInterval(interval: interval!)
        prefHandler.savePreferences()
        self.dismiss(self)
    }
    
}

