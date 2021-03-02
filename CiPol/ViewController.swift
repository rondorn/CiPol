//
//  ViewController.swift
//  CiPol
//
//  Created by Ron Dorn on 2/10/21.
//

import Cocoa
import SafariServices

class ViewController: NSViewController, NSWindowDelegate  {


    @IBOutlet weak var jobsTable: NSTableView!
    
    @IBOutlet weak var addServerButton: NSButton!
    @IBOutlet weak var addJobButton: NSButton!
    @IBOutlet weak var refreshDataButton: NSButton!
    @IBOutlet weak var setPollingIntervalButton: NSButton!
    @IBOutlet weak var busyIndicator: NSProgressIndicator!
    
    let prefHandler = PrefHandler()
    let testingHandler = BackgroundTesting()

    
    var firstLaunch = true
    
    var jobsData = [String: JenkinsJobPrefHandler]()
    var jobList: [String] = []
    var tableData = [Int:[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        busyIndicator.isHidden = true
        // Do any additional setup after loading the view.
        loadPreferences()
        
        jobsTable.delegate = self
        jobsTable.dataSource = self
        
        setupRightClickMenu()
        
        jobsTable.reloadData()
                
        NotificationCenter.default.addObserver(self, selector: #selector(refreshDataPressed), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNewJob), name: NSNotification.Name(rawValue: "jobAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reopenWindow), name: NSNotification.Name(rawValue: "zoom"), object: nil)
        collectDataFromBackground()
        
        self.view.window?.titleVisibility = .hidden
        self.view.window?.titlebarAppearsTransparent = true

        self.view.window?.styleMask.insert(.fullSizeContentView)

        self.view.window?.styleMask.remove(.closable)
        self.view.window?.styleMask.remove(.fullScreen)
        self.view.window?.styleMask.remove(.miniaturizable)
        self.view.window?.styleMask.remove(.resizable)
        
        preferredContentSize = view.frame.size
     
    }
    
    
    @objc func reopenWindow(){
        if (view.window?.screen ?? NSScreen.main) != nil {
            view.window!.setIsMiniaturized(false)
        }
    }
    
    override func viewWillAppear() {
        self.view.window?.standardWindowButton(NSWindow.ButtonType.closeButton)?.isEnabled = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.window?.delegate = self
    }
    
    func windowShouldClose(sender: AnyObject) -> Bool {
        print ("Trying to code windows")
        NSApp.hide(nil)
        return false
    }
    
    func collectDataFromBackground(){
        
        DispatchQueue.global(qos: .background).async {
            
            self.testingHandler.runTests(prefHandler: self.prefHandler, firstLaunch: self.firstLaunch)
            
            DispatchQueue.main.async {
                self.refreshData()
                self.collectDataFromBackground();
                self.sendAlerts()
                self.firstLaunch = false
            }
        }
        
    }
    
    @objc private func tableViewDeleteItemClicked(_ sender: AnyObject) {
        
        print ("Delete from table")
        guard jobsTable.clickedRow >= 0 else { return }

        let jobName = self.tableData[jobsTable.clickedRow]!["jobName"]
        prefHandler.removeJenkinsJob(jobName: jobName!)
        
        refreshData()
    }
 
    @objc private func cloneJobOnClick(_ sender: AnyObject) {
        
        print ("Clone from table")
        guard jobsTable.clickedRow >= 0 else { return }

        let jobName = self.tableData[jobsTable.clickedRow]!["jobName"]
        
        Utilties.activeJobRecord = jobName ?? "";
        
        performSegue(withIdentifier: NSStoryboardSegue.Identifier("addEditJob"), sender: nil)
        
    }
    
    @objc func openJenkinsUrl(_ sender: AnyObject){
        
        guard jobsTable.clickedRow >= 0 else { return }
        
        let jobName = self.tableData[jobsTable.clickedRow]!["jobName"]
        let rootUrl = prefHandler.getServerDetails(serverName: self.tableData[jobsTable.clickedRow]!["serverName"]!).getServerUrl()
        var jenkinsUrl = rootUrl + "/job/" + jobName!
        
        jenkinsUrl = jenkinsUrl.replacingOccurrences(of: "/job//job/", with: "/job/")
        
        jenkinsUrl = Utilties.cleanUpURL(url: jenkinsUrl)
        
        print ("Opening up URL of \(jenkinsUrl)")
        guard let url = URL(string: jenkinsUrl) else { return }
        
        NSWorkspace.shared.open(url)

    }

    @objc private func enableMonitoring(_ sender: AnyObject) {
        
        guard jobsTable.clickedRow >= 0 else { return }

        let jobName = self.tableData[jobsTable.clickedRow]!["jobName"]
        let jobData = prefHandler.getJobDetails(jobName: jobName!)
        
        jobData.setMonitoring(monitoring: true)
        prefHandler.setJenkinsJobData(jobName: jobName!, jobData: jobData)
        prefHandler.savePreferences()
        
        refreshData()
    }
    
    private func toggleMonitoring(jobName: String) {
        
        guard jobsTable.clickedRow >= 0 else { return }

        let jobName = self.tableData[jobsTable.clickedRow]!["jobName"]
        let jobData = prefHandler.getJobDetails(jobName: jobName!)
        
        var monValue = Bool()
        
        if (jobData.getMonitoring() == true){
            monValue = false
        } else {
            monValue = true
        }
        jobData.setMonitoring(monitoring: monValue)
        prefHandler.setJenkinsJobData(jobName: jobName!, jobData: jobData)
        prefHandler.savePreferences()
        
        refreshData()
    }
    
    @objc private func onItemClicked(_ sender: AnyObject) {
        
        let row = jobsTable.clickedRow
        let column = jobsTable.clickedColumn
        
        if (row >= 0) {
            let jobName = self.tableData[row]!["jobName"]
            if (column == 0){
                toggleMonitoring(jobName: jobName!);
            }
        }
        
    }
    
    func setupRightClickMenu(){
    
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Clone Job", action: #selector(cloneJobOnClick(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Delete Job", action: #selector(tableViewDeleteItemClicked(_:)), keyEquivalent: ""))
        jobsTable.menu = menu
        
        jobsTable.doubleAction = #selector(openJenkinsUrl(_:))
        jobsTable.action = #selector(onItemClicked)
    }
    
    func sendAlerts(){
        
        let notificationHandle = NotificationHandler()
        
        var testsPassing = [String]()
        var testsFailing = [String]()
        var testsUnknown = [String]()
        
        for jobName in BackgroundTesting.alertData {
            let jobDetails = prefHandler.getJobDetails(jobName: jobName.key)
            if (jobDetails.getMonitoring() == true){
                if jobName.value == Utilties.testPassed {
                    testsPassing.append(jobName.key)
                    
                } else if jobName.value == Utilties.testFailed {
                    testsFailing.append(jobName.key)
                    
                } else {
                    testsUnknown.append(jobName.key)
                    
                }
            }
        }
        
        if (testsPassing.count == 1){
            notificationHandle.showNotification(jobName: testsPassing.first!, jobStatus: Utilties.testPassed)
            
        } else if (testsPassing.count > 1){
            notificationHandle.showNotification(jobNames: testsPassing, jobStatus: Utilties.testPassed)
        }

        if (testsFailing.count == 1){
            notificationHandle.showNotification(jobName: testsFailing.first!, jobStatus: Utilties.testFailed)
            
        } else if (testsFailing.count > 1){
            notificationHandle.showNotification(jobNames: testsFailing, jobStatus: Utilties.testFailed)
        }
        
        if (testsUnknown.count == 1){
            notificationHandle.showNotification(jobName: testsUnknown.first!, jobStatus: Utilties.testUnknown)
            
        } else if (testsUnknown.count > 1){
            notificationHandle.showNotification(jobNames: testsUnknown, jobStatus: Utilties.testUnknown)
        }
        
        BackgroundTesting.alertData = [String:String]()
    }
    
    override func viewDidAppear(){
        super.viewDidAppear()
    }
    
    @objc func refreshData(){
        
        self.loadPreferences()
        self.loadPreferences()
        self.jobsTable.reloadData()
    }
    
    func loadPreferences(){
        prefHandler.loadPreferences();
        self.jobsData = prefHandler.getJenkinsJobData()
        self.jobList = prefHandler.getListOfJobs()
        self.populateTableData()
    }
        
    func reloadFileList() {
        jobsTable.reloadData()
    }

    func populateTableData(){
        
        var counter = 0
        
        var trayIcon = Utilties.greenTextIcon
        var oneFailing = false
        
        for jobName in self.jobList {
            let jobDetails = prefHandler.getJobDetails(jobName: jobName)
            var jobDetailsData = [String:String]()
                
            jobDetailsData["passFail"] = Utilties.getPassFailIcon(status: jobDetails.getLastJobStatus())
            jobDetailsData["jobName"] = jobDetails.getJobName()
            jobDetailsData["serverName"] = jobDetails.getServerRecord()
            jobDetailsData["status"] = jobDetails.getStatus()
            jobDetailsData["lastRan"] = jobDetails.getLastTested()
            jobDetailsData["lastRanDiff"] = String(jobDetails.getLastTestedDiff())
            jobDetailsData["lastPolled"] = jobDetails.getLastPolled()
            jobDetailsData["monitoring"] = String(jobDetails.getMonitoring())
            
            //make job name more user friendly
            let displayName  = jobDetailsData["jobName"]! .replacingOccurrences(of: "/job/", with: "-")
            let regex = try! NSRegularExpression(pattern: "^-")
            let range = NSMakeRange(0, 1)
            
            if (displayName.isEmpty == false){
                jobDetailsData["displayName"]  = regex.stringByReplacingMatches(in: displayName , options: [], range: range, withTemplate: "")
            } else {
                jobDetailsData["displayName"]  = jobName
            }
            
            let jobStatus = jobDetails.getLastJobStatus()
            
            print ("jobStatus for trayIcon = \(jobStatus)")
            if (jobStatus != Utilties.testPassed){
                if (jobDetails.getMonitoring() == true && jobStatus == Utilties.testFailed){
                    trayIcon = Utilties.redTextIcon
                    oneFailing = true
                    print ("trayIcon is \(trayIcon) bad loop")
                    
                } else if (jobDetails.getMonitoring() && oneFailing == false){
                    trayIcon = Utilties.greyTextIcon
                    print ("trayIcon is \(trayIcon) grey loop")
                }
            }
            
            self.tableData[counter] = jobDetailsData
            counter = counter + 1
        }
        
        determineStatusIcon(trayIcon: trayIcon)
        
        if (prefHandler.getSortingField().isEmpty == true){
            sortTableData(sortBy: "displayName", accending: true)
        } else {
            sortTableData(sortBy: prefHandler.getSortingField(), accending: prefHandler.getSortingDirection())
        }
    }
    
    func determineStatusIcon(trayIcon: String){
        
        print ("trayIcon is \(trayIcon)")
        let trayText = "CiPol"
        
        let fontData = NSFont.systemFont(ofSize: CGFloat(Utilties.trayFontSize), weight: Utilties.trayFontWeight)
        
        
        var trayColor = [ NSAttributedString.Key.foregroundColor: NSColor.systemGray, NSAttributedString.Key.font: fontData ]
        
        if (trayIcon == Utilties.redTextIcon){
            trayColor = [ NSAttributedString.Key.foregroundColor: NSColor.systemRed, NSAttributedString.Key.font: fontData ]
        
        } else if (trayIcon == Utilties.greenTextIcon){
            trayColor = [ NSAttributedString.Key.foregroundColor: NSColor.systemGreen, NSAttributedString.Key.font: fontData ]

        }

        let trayValue = NSAttributedString(string: trayText, attributes: trayColor)
        AppDelegate.statusItem?.button?.attributedTitle = trayValue
        
    }
        
    func sortTableData(sortBy: String, accending: Bool){
        print ("Sort Info - \(sortBy) - \(accending)")
        
        var sortingHash1 = [String:[String:String]]();
        var sortingHash2 = [String:[String:String]]();
        
        for tableRecord in self.tableData {
            var index = tableRecord.value["displayName"]!
            index = index.uppercased()
            sortingHash1[index] = tableRecord.value
            
        }
        
        var sortedKey1 = [String]()
        
        if (accending == true){
            sortedKey1 = sortingHash1.keys.sorted()
        } else {
            sortedKey1 = sortingHash1.keys.sorted().reversed()
        }
        
        var counter = 0
        for sortIndex in sortedKey1{
            let counterString = String(format: "%03d", counter)
            var index = sortingHash1[sortIndex]![sortBy]! + "-\(counterString)"
            
            index = index.uppercased()
            print ("Sort Info - index is \(sortBy) \(index)")
            sortingHash2[index] = sortingHash1[sortIndex]
            counter = counter + 1
        }
        
        var sortedKey2 = [String]()
        
        if (accending == false){
            if (sortBy == "lastRanDiff"){
                sortedKey2 = sortingHash2.keys.sorted(by: {$0.localizedStandardCompare($1) == .orderedDescending})
            } else {
                sortedKey2 = sortingHash2.keys.sorted(by: {$0 > $1})
            }
        } else {
            if (sortBy == "lastRanDiff"){
                sortedKey2 = sortingHash2.keys.sorted(by: {$0.localizedStandardCompare($1) == .orderedAscending})
            } else {
                sortedKey2 = sortingHash2.keys.sorted(by: {$0 < $1})
            }
        }
    
        counter = 0
        for sortIndex in sortedKey2{
            self.tableData[counter] = sortingHash2[sortIndex]
            counter = counter + 1
        }
        
        prefHandler.setSortingField(value: sortBy)
        prefHandler.setSortingDirection(value: accending)
        prefHandler.savePreferences()
        
        jobsTable.reloadData()
    }
    
    @IBSegueAction func addJobSegue(_ coder: NSCoder) -> AddJobController? {
        print ("Button add job pressed")
        return AddJobController(coder: coder)
    }
    
    @IBAction func addServerPressed(_ sender: Any) {
        print ("Button add server pressed")
    }
    
    
    @IBAction func addJobPressed(_ sender: Any) {
        print ("Button add job pressed")
        
    }
    
    @IBAction func refreshDataPressed(_ sender: Any) {
        print ("Button refresh data pressed")
        
        if (Utilties.runningRefresh == false){
            Utilties.runningRefresh = true
            busyIndicator.isHidden = false
            busyIndicator.startAnimation(sender)
            DispatchQueue.global(qos: .background).async {
                self.testingHandler.runTests(prefHandler: self.prefHandler, firstLaunch: true)
                
                DispatchQueue.main.async {
                    self.refreshData()
                    self.sendAlerts()
                    self.busyIndicator.isHidden = true
                    self.busyIndicator.stopAnimation(sender)
                    Utilties.runningRefresh = false
                }
            }
        }
    }
    
    @IBAction func refreshNewJob(_ sender: Any) {
        
        self.prefHandler.loadPreferences()
        
        DispatchQueue.global(qos: .background).async {
            self.testingHandler.runNewTests(prefHandler: self.prefHandler, firstLaunch: true)
            
            DispatchQueue.main.async {
                self.refreshData()
            }
        }
        
    }
    
    @IBAction func setPollingPressed(_ sender: Any) {
        print ("Button set polling pressed")
        
    }
    
    @IBAction func SortEvent(_ sender: NSTableView) {
        print ("Sort info section 2")
    }
    
}

extension ViewController: NSTableViewDataSource {
  
  func numberOfRows(in jobsTable: NSTableView) -> Int {
    return jobsData.count
  }

}

extension ViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let monitoringId = "monitoringId"
    static let passFailId = "passFailTextId"
    static let jobNameId = "jobNameId"
    static let serverNameId = "serverNameId"
    static let statusID = "statusId"
    static let lastPooledId = "lastPolledId"
    static let lastRanId = "lastRanId"
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
        text = Utilties.getMonitoringIcon(status: tableData[row]!["monitoring"]!)
        cellIdentifier = CellIdentifiers.monitoringId
        
    } else if tableColumn == tableView.tableColumns[1] {
        text = tableData[row]!["passFail"]!
        cellIdentifier = CellIdentifiers.passFailId
        
    } else if tableColumn == tableView.tableColumns[2] {
        text = tableData[row]!["displayName"]!
        cellIdentifier = CellIdentifiers.jobNameId
        
    } else if tableColumn == tableView.tableColumns[3] {
        text = tableData[row]!["serverName"]!
        cellIdentifier = CellIdentifiers.serverNameId
        
    } else if tableColumn == tableView.tableColumns[4] {
        text = tableData[row]!["status"]!
        cellIdentifier = CellIdentifiers.statusID
        
    } else if tableColumn == tableView.tableColumns[5] {
        text = tableData[row]!["lastRan"]!
        cellIdentifier = CellIdentifiers.lastRanId
        
    } else if tableColumn == tableView.tableColumns[6] {
        text = tableData[row]!["lastPolled"]!
        cellIdentifier = CellIdentifiers.lastPooledId
        
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        cell.textField?.stringValue = text
        return cell
    }
    
    return nil
  }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
        guard let descriptor = tableView.sortDescriptors.first else { return }
        
        sortTableData(sortBy: descriptor.key!, accending: descriptor.ascending)

    }

}

