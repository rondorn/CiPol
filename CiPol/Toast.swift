//
//  Toast.swift
//  CiPol
//
//  Created by Ron Dorn on 2/10/21.
//

import Foundation
import AppKit

class Toast {
    
    static func displayMesssage(title: String, message: String)-> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
    
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func displayInfo(title: String, message: String)->Bool {
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = title
        alert.alertStyle = NSAlert.Style.informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
    
        return alert.runModal() == .alertFirstButtonReturn
    }
}
