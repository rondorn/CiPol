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
    var control: ViewController?
    
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
        
        viewWindow(sender)
        
        _ = Toast.displayInfo(title: "", message: message)
        
    }
    
    @objc func viewWindow(_ sender: Any?) {
        
        print("AppDelegate: viewWindow called - forcing window to front")
        
        // Force app activation immediately
        NSApp.activate(ignoringOtherApps: true)
        NSApp.unhide(nil)
        
        // Find and activate the main application window directly
        var foundWindow = false
        for window in NSApp.windows {
            // Skip status bar and other system windows
            if window.isVisible || window.isMiniaturized {
                if window.canBecomeKey && window.contentViewController != nil {
                    print("AppDelegate: Found and activating window: \(window)")
                    
                    // Restore if minimized
                    if window.isMiniaturized {
                        window.deminiaturize(nil)
                    }
                    
                    // Force window to front with multiple methods
                    window.makeKeyAndOrderFront(nil)
                    window.orderFrontRegardless()
                    window.setIsVisible(true)
                    window.collectionBehavior = .moveToActiveSpace
                    
                    foundWindow = true
                    break
                }
            }
        }
        
        // If no window found, use the notification system as fallback
        if !foundWindow {
            print("AppDelegate: No window found, using notification fallback")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "zoom"), object: nil)
        }
        
        // Multiple delayed activations to ensure it sticks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.activate(ignoringOtherApps: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.activate(ignoringOtherApps: true)
        }
        
    }
    

    
    @objc func refreshData(_ sender: Any?) {
        
        //storyboard.performSegue(withIdentifier: "newWindow", sender: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        NSApp.activate(ignoringOtherApps: true)
        
    }
    
    @objc func quitApp(_ sender: Any?) {
        print("quit button was pressed")
        exit(0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About CiPol", action: #selector(aboutMenu(_:)), keyEquivalent: ""))
        menu.insertItem(NSMenuItem.separator(), at: 1)
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(viewWindow(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refreshData(_:)), keyEquivalent: ""))
        menu.insertItem(NSMenuItem.separator(), at: 4)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp(_:)), keyEquivalent: ""))
        
        AppDelegate.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let trayText = "CiPol"
        let trayColor: [NSAttributedString.Key: Any]  = [ NSAttributedString.Key.foregroundColor: NSColor.systemGreen, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12, weight: NSFont.Weight.bold)]
        let trayValue = NSAttributedString(string: trayText, attributes: trayColor)
        AppDelegate.statusItem?.button?.attributedTitle = trayValue
        
        AppDelegate.statusItem?.menu = menu
    }
}


