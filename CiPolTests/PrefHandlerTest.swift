//
//  PrefHandlerTest.swift
//  CI-MonitorTests
//
//  Created by Ron Dorn on 2/6/21.
//

import XCTest
@testable import CiPol

class PrefHandlerTest: XCTestCase {
        
    override func setUpWithError() throws {
        //try self.createDataAndWriteIt()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDataAndWriteIt() throws {
        
        let prefHandler = PrefHandler()
        
        prefHandler.setPollingInterval(interval: 10)

        let testServerData1 = JenkinsServerPrefHandler()
        testServerData1.setServerName(serverName: "testServer1")
        testServerData1.setServerUrl(serverUrl: "https://testing1.test.net")
        testServerData1.setUserName(userName: "rdorn")
        testServerData1.setUserPassword(userPassword: "123", severName: "testServer1")
        prefHandler.setJenkinsServerData(serverName: "testServer1", serverData: testServerData1)

        let testServerData2 = JenkinsServerPrefHandler()
        testServerData2.setServerName(serverName: "Test Server 2")
        testServerData2.setServerUrl(serverUrl: "https://testing2.test.net")
        testServerData2.setUserName(userName: "rdorn")
        testServerData2.setUserPassword(userPassword: "456", severName: "Test Server 2")
        prefHandler.setJenkinsServerData(serverName: "testServer2", serverData: testServerData2)
        
        let testJobData1 = JenkinsJobPrefHandler()
        testJobData1.setServerRecord(serverRecord: "Test Server 1")
        testJobData1.setJobName(jobName: "testJob1")
        testJobData1.setLastJobStatus(lastJobStatus: "Failed")
        testJobData1.setStatus(status: "Idle")
        prefHandler.setJenkinsJobData(jobName: "testJob1", jobData: testJobData1)
 
        let testJobData2 = JenkinsJobPrefHandler()
        testJobData2.setServerRecord(serverRecord: "Test Server 2")
        testJobData2.setJobName(jobName: "testJob2")
        testJobData2.setLastJobStatus(lastJobStatus: "Passed")
        testJobData2.setStatus(status: "In Progress")
        prefHandler.setJenkinsJobData(jobName: "testJob2", jobData: testJobData2)
        
        prefHandler.savePreferences()

    }

    func testReadPrefData() throws {
        
        let prefHandler = PrefHandler()
        
        prefHandler.loadPreferences();
        
        //XCTAssertEqual(product.price, 20)
        
        let pollingInternal = prefHandler.getPollingInterval();
        
        print ("pollingInternal is \(pollingInternal)")
        XCTAssertEqual(pollingInternal, 10)
        
        let jobList = prefHandler.getListOfJobs()
        print ("List Of Jobs is \(jobList)")
        
        let jobOneDetails = prefHandler.getJobDetails(jobName: "testJob1")
        XCTAssertEqual(jobOneDetails.getServerRecord(), "Test Server 1")
        XCTAssertEqual(jobOneDetails.getLastJobStatus(), "Failed")

        let jobTwoDetails = prefHandler.getJobDetails(jobName: "testJob2")
        XCTAssertEqual(jobTwoDetails.getServerRecord(), "Test Server 2")
        XCTAssertEqual(jobTwoDetails.getLastJobStatus(), "Passed")
        
    }
}
