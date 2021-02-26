//
//  AppDelegate.swift
//  CiPol
//
//  Created by Ron Dorn on 2/10/21.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, NSWindowDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    static var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print ("Launuching CiPol!!")
        // Override point for customization after application launch.
        
        // set app delegate as notification center delegate
        UNUserNotificationCenter.current().delegate = self
            
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
                
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func aboutMenu(_ sender: Any) {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        var message = "CiPol\n"
        message += "version " + version + " (" + build + ")\n"
        message += "Written by Ron Dorn\n"
        message += "©All Rights Reserved\n"
        message += "Distributed via GPLv2 License\n"
        
        _ = Toast.displayInfo(title: "", message: message)
    }
    
    @objc func viewWindow(_ sender: Any?) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "zoom"), object: nil)
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    @objc func quitApp(_ sender: Any?) {
        print("quit button was pressed")
        exit(0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let trayIcon = "CiPol 🟢"
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About CiPol", action: #selector(aboutMenu(_:)), keyEquivalent: ""))
        menu.insertItem(NSMenuItem.separator(), at: 1)
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(viewWindow(_:)), keyEquivalent: ""))
        menu.insertItem(NSMenuItem.separator(), at: 3)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp(_:)), keyEquivalent: ""))
        
        AppDelegate.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        AppDelegate.statusItem?.button?.title = trayIcon
        AppDelegate.statusItem?.menu = menu
    }
}


