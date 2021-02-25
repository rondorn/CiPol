//
//  ServerAdminController.swift
//  CiPol
//
//  Created by Ron Dorn on 2/12/21.
//

import Foundation
import Cocoa

class ServerAdminController: NSViewController {
    
    let prefHandler = PrefHandler()
    var tableData = [Int:[String:String]]()

    @IBOutlet weak var hiddenSegueButton: NSButton!
    
    @IBOutlet weak var serversTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        serversTable.target = self
        serversTable.doubleAction = #selector(doubleClickOnTable)
        
        serversTable.delegate = self
        serversTable.dataSource = self
        
        populateTableData()
        setupRightClickMenu()
        
        hiddenSegueButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(populateTableData), name: NSNotification.Name(rawValue: "loadServer"), object: nil)
   
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        print ("Edit from table")
        guard serversTable.clickedRow >= 0 else { return }
        let serverName = self.tableData[serversTable.clickedRow]!["serverNameId"]
        Utilties.activeServerRecord = serverName!

    }
    
    @objc  func doubleClickOnTable(_ sender: Any) {
        print("doubleClickOnResultRow \(serversTable.clickedRow)")
        if (serversTable.selectedRow > -1 ) {
            performSegue(withIdentifier: NSStoryboardSegue.Identifier("addEditServer"), sender: nil)
        }
    }

    
    @objc func populateTableData(){
        
        tableData = [Int:[String:String]]()
        var counter = 0
        prefHandler.loadPreferences();
        let servers = prefHandler.getListOfServers()

        for serverName in servers {
            let serverDetails = prefHandler.getServerDetails(serverName: serverName)
            var serverDetailsData = [String:String]()
                
            serverDetailsData["serverNameId"] = serverDetails.getServerName()
            serverDetailsData["serverUrlId"] = serverDetails.getServerUrl()
            serverDetailsData["userNameId"] = serverDetails.getUserName()
            
            self.tableData[counter] = serverDetailsData
            counter = counter + 1
        }
        
        serversTable.reloadData()
        
    }
        
    func setupRightClickMenu(){
    
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Delete Server", action: #selector(deleteServer(_:)), keyEquivalent: ""))
        serversTable.menu = menu
        
    }
    
    @objc func editServerRecord(_ sender: AnyObject) {
    
        print ("Edit from table")
        guard serversTable.clickedRow >= 0 else { return }
        let serverName = self.tableData[serversTable.clickedRow]!["serverNameId"]
        Utilties.activeServerRecord = serverName!
    }
    
    @objc private func deleteServer(_ sender: AnyObject) {
        
        print ("Delete from table")
        guard serversTable.clickedRow >= 0 else { return }

        let serverName = self.tableData[serversTable.clickedRow]!["serverNameId"]
        let listOfJobs = prefHandler.getAllJobForServer(serverRecord: serverName!)
        
        if (listOfJobs.isEmpty == true){
            prefHandler.removeJenkinsServer(serverName: serverName!)

        } else {
            _ = Toast.displayMesssage(title: "Alert", message: "This server is in use by job " + listOfJobs.first!)
        }
        
        populateTableData()
    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        self.dismiss(self)
    }
    
    @IBAction func addServerButtonPressed(_ sender: Any) {
        Utilties.activeServerRecord = ""
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("addEditServer"), sender: nil)
    }
    
    
}


extension ServerAdminController: NSTableViewDataSource {
  
  func numberOfRows(in jobsTable: NSTableView) -> Int {
    return tableData.count
  }

}

extension ServerAdminController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let serverNameId = "serverNameId"
    static let serverUrlId = "serverUrlId"
    static let userNameId = "userNameId"


  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

    var text: String = ""
    var cellIdentifier = ""
    
    // 1
    guard self.tableData[row] != nil else {
      return nil
    }
    
    //print ("Setting value for cell workking on tableColumn \(tableColumn?.headerCell.title)")
    // 2
    if tableColumn == tableView.tableColumns[0] {
        text = tableData[row]!["serverNameId"]!
        cellIdentifier = CellIdentifiers.serverNameId
        
    } else if tableColumn == tableView.tableColumns[1] {
        text = tableData[row]!["serverUrlId"]!
        cellIdentifier = CellIdentifiers.serverUrlId
        
    } else if tableColumn == tableView.tableColumns[2] {
        text = tableData[row]!["userNameId"]!
        cellIdentifier = CellIdentifiers.userNameId
        
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    
    return nil
  }
    
}
