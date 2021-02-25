//
//  JenkinsCommuncationHandlerTest.swift
//  CI-MonitorTests
//
//  Created by Ron Dorn on 2/7/21.
//

import XCTest
@testable import CiPol

class JenkinsCommuncationHandlerTest: XCTestCase {
    
    var testJenkinsResult1 = ""
    var testJenkinsResult2 = ""
    let prefHandler = PrefHandler()
    
    override func setUpWithError() throws {
                
        prefHandler.setPollingInterval(interval: 10)

        let testServerData1 = JenkinsServerPrefHandler()
        testServerData1.setServerName(serverName: "testServer1")
        testServerData1.setServerUrl(serverUrl: "https://servicemanagementseleniumtestsci.dop.sfdc.net")
        testServerData1.setUserName(userName: "rdorn")
        testServerData1.setUserPassword(userPassword: "123", severName: "testServer1")
        prefHandler.setJenkinsServerData(serverName: "testServer1", serverData: testServerData1)

        let testServerData2 = JenkinsServerPrefHandler()
        testServerData2.setServerName(serverName: "testServer2")
        testServerData2.setServerUrl(serverUrl: "https://servicemanagementseleniumtestsci.tst.dop.sfdc.net")
        testServerData2.setUserName(userName: "rdorn")
        testServerData2.setUserPassword(userPassword: "456", severName: "testServer2")
        prefHandler.setJenkinsServerData(serverName: "testServer2", serverData: testServerData1)
        
        let testJobData1 = JenkinsJobPrefHandler()
        testJobData1.setServerRecord(serverRecord: "testServer1")
        testJobData1.setJobName(jobName: "testJob1")
        testJobData1.setLastJobStatus(lastJobStatus: "Failed")
        testJobData1.setStatus(status: "Idle")
        prefHandler.setJenkinsJobData(jobName: "testJob1", jobData: testJobData1)
 
        let testJobData2 = JenkinsJobPrefHandler()
        testJobData2.setServerRecord(serverRecord: "testServer2")
        testJobData2.setJobName(jobName: "testJob2")
        testJobData2.setLastJobStatus(lastJobStatus: "Passed")
        testJobData2.setStatus(status: "In Progress")
        prefHandler.setJenkinsJobData(jobName: "testJob2", jobData: testJobData2)
        
        self.testJenkinsResult1 = "{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowJob\",\"actions\":[{},{},{},{},{}"
        self.testJenkinsResult1 += ",{},{},{},{},{},{\"_class\":\"hudson.plugins.jobConfigHistory."
        self.testJenkinsResult1 += "JobConfigHistoryProjectAction\"},{},{},{},{\"_class\":\"nectar.plugins.rbac.roles.Roles\"}"
        self.testJenkinsResult1 += ",{},{},{},{},{},{},{\"_class\":\"com.cloudbees.plugins.credentials.ViewCredentialsAction\""
        self.testJenkinsResult1 += "}],\"description\":\"This is sample json representing typical jenkins output"
        self.testJenkinsResult1 += "\",\"displayName\":\"testJenkinsJob\",\""
        self.testJenkinsResult1 += "displayNameOrNull\":null,\"fullDisplayName\":\"testJenkinsJob\",\"fullName\":\"testJenkinsJob\","
        self.testJenkinsResult1 += "\"name\":\"testJenkinsJob\",\"url\":\"https://testJenkinsServer.nowhere.net/"
        self.testJenkinsResult1 += "job/testJenkinsJob/\",\"buildable\":true,\"builds\":[{\"_class\":\"org.jenkinsci.plugins."
        self.testJenkinsResult1 += "workflow.job.WorkflowRun\",\"number\":108,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":107,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/107/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":106,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/106/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":105,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/105/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":104,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/104/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":103,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/103/\"},{\"_class\":\"org."
        self.testJenkinsResult1 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":102,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/102/\"}],\"color\":\"blue\","
        self.testJenkinsResult1 += "\"firstBuild\":{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":"
        self.testJenkinsResult1 += "102,\"url\":\"https://testJenkinsServer.nowhere.net/job/testJenkinsJob/102/\""
        self.testJenkinsResult1 += "},\"healthReport\":[{\"description\":\"Build stability: No recent builds "
        self.testJenkinsResult1 += "failed.\",\"iconClassName\":\"icon-health-80plus\",\"iconUrl\":\"health-80plus.png\",\""
        self.testJenkinsResult1 += "score\":100}],\"inQueue\":false,\"keepDependencies\":false,\"lastBuild\":{\"_class\":\"org"
        self.testJenkinsResult1 += ".jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":108,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\"lastCompletedBuild"
        self.testJenkinsResult1 += "\":{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":108,\"url\":"
        self.testJenkinsResult1 += "\"https://testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\""
        self.testJenkinsResult1 += "lastFailedBuild\":null,\"lastStableBuild\":{\"_class\":\"org.jenkinsci.plugins.workflow."
        self.testJenkinsResult1 += "job.WorkflowRun\",\"number\":108,\"url\":\"https://servicemanagementseleniumtestsci.dop."
        self.testJenkinsResult1 += "sfdc.net/job/testJenkinsJob/108/\"},\"lastSuccessfulBuild\":{\"_class\":\"org.jenkinsci."
        self.testJenkinsResult1 += "plugins.workflow.job.WorkflowRun\",\"number\":108,\"url\":\"https://"
        self.testJenkinsResult1 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\"lastUnstableBuild"
        self.testJenkinsResult1 += "\":null,\"lastUnsuccessfulBuild\":null,\"nextBuildNumber\":109,\"property\":[{\"_class\":\""
        self.testJenkinsResult1 += "hudson.plugins.jira.JiraProjectProperty\"},{\"_class\":\"com.coravy.hudson.plugins.github."
        self.testJenkinsResult1 += "GithubProjectProperty\"},{\"_class\":\"com.cloudbees.opscenter.analytics.reporter.items."
        self.testJenkinsResult1 += "AnalyticsJobProperty\"},{\"_class\":\"org.jenkinsci.plugins.workflow.job.properties."
        self.testJenkinsResult1 += "DisableConcurrentBuildsJobProperty\"},{\"_class\":\"org.jenkinsci.plugins.workflow.job."
        self.testJenkinsResult1 += "properties.PipelineTriggersJobProperty\"},{\"_class\":\"jenkins.model."
        self.testJenkinsResult1 += "BuildDiscarderProperty\"}],\"queueItem\":null,\"concurrentBuild\":false,\"resumeBlocked\":"
        self.testJenkinsResult1 += "false}"

        self.testJenkinsResult2 = "{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowJob\",\"actions\":[{},{},{},{},{}"
        self.testJenkinsResult2 += ",{},{},{},{},{},{\"_class\":\"hudson.plugins.jobConfigHistory."
        self.testJenkinsResult2 += "JobConfigHistoryProjectAction\"},{},{},{},{\"_class\":\"nectar.plugins.rbac.roles.Roles\"}"
        self.testJenkinsResult2 += ",{},{},{},{},{},{},{\"_class\":\"com.cloudbees.plugins.credentials.ViewCredentialsAction\""
        self.testJenkinsResult2 += "}],\"description\":\"This is sample json representing typical jenkins output"
        self.testJenkinsResult2 += "\",\"displayName\":\"testJenkinsJob\",\""
        self.testJenkinsResult2 += "displayNameOrNull\":null,\"fullDisplayName\":\"testJenkinsJob\",\"fullName\":\"testJenkinsJob\","
        self.testJenkinsResult2 += "\"name\":\"testJenkinsJob\",\"url\":\"https://testJenkinsServer.nowhere.net/"
        self.testJenkinsResult2 += "job/testJenkinsJob/\",\"buildable\":true,\"builds\":[{\"_class\":\"org.jenkinsci.plugins."
        self.testJenkinsResult2 += "workflow.job.WorkflowRun\",\"number\":108,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":107,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/107/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":106,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/106/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":105,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/105/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":104,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/104/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":103,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/103/\"},{\"_class\":\"org."
        self.testJenkinsResult2 += "jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":102,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/102/\"}],\"color\":\"blue\","
        self.testJenkinsResult2 += "\"firstBuild\":{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":"
        self.testJenkinsResult2 += "102,\"url\":\"https://testJenkinsServer.nowhere.net/job/testJenkinsJob/102/\""
        self.testJenkinsResult2 += "},\"healthReport\":[{\"description\":\"Build stability: No recent builds "
        self.testJenkinsResult2 += "failed.\",\"iconClassName\":\"icon-health-80plus\",\"iconUrl\":\"health-80plus.png\",\""
        self.testJenkinsResult2 += "score\":100}],\"inQueue\":false,\"keepDependencies\":false,\"lastBuild\":{\"_class\":\"org"
        self.testJenkinsResult2 += ".jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":108,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\"lastCompletedBuild"
        self.testJenkinsResult2 += "\":{\"_class\":\"org.jenkinsci.plugins.workflow.job.WorkflowRun\",\"number\":108,\"url\":"
        self.testJenkinsResult2 += "\"https://testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\""
        self.testJenkinsResult2 += "lastFailedBuild\":null,\"lastStableBuild\":{\"_class\":\"org.jenkinsci.plugins.workflow."
        self.testJenkinsResult2 += "job.WorkflowRun\",\"number\":108,\"url\":\"https://servicemanagementseleniumtestsci.dop."
        self.testJenkinsResult2 += "sfdc.net/job/testJenkinsJob/108/\"},\"lastSuccessfulBuild\":{\"_class\":\"org.jenkinsci."
        self.testJenkinsResult2 += "plugins.workflow.job.WorkflowRun\",\"number\":107,\"url\":\"https://"
        self.testJenkinsResult2 += "testJenkinsServer.nowhere.net/job/testJenkinsJob/108/\"},\"lastUnstableBuild"
        self.testJenkinsResult2 += "\":null,\"lastUnsuccessfulBuild\":null,\"nextBuildNumber\":109,\"property\":[{\"_class\":\""
        self.testJenkinsResult2 += "hudson.plugins.jira.JiraProjectProperty\"},{\"_class\":\"com.coravy.hudson.plugins.github."
        self.testJenkinsResult2 += "GithubProjectProperty\"},{\"_class\":\"com.cloudbees.opscenter.analytics.reporter.items."
        self.testJenkinsResult2 += "AnalyticsJobProperty\"},{\"_class\":\"org.jenkinsci.plugins.workflow.job.properties."
        self.testJenkinsResult2 += "DisableConcurrentBuildsJobProperty\"},{\"_class\":\"org.jenkinsci.plugins.workflow.job."
        self.testJenkinsResult2 += "properties.PipelineTriggersJobProperty\"},{\"_class\":\"jenkins.model."
        self.testJenkinsResult2 += "BuildDiscarderProperty\"}],\"queueItem\":null,\"concurrentBuild\":false,\"resumeBlocked\":"
        self.testJenkinsResult2 += "false}"
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testJenkinsCommunicationPassing() throws {
        
        let communicationHandle = JenkinsCommuncationHandler()
        
        communicationHandle.setTestData(testData: self.testJenkinsResult1)
        
        let testJobData1 = self.prefHandler.getJobDetails(jobName: "testJob1")
        let status1 = communicationHandle.getJobResults(preferences: self.prefHandler, jobData: testJobData1)
        
        let notificationHandle = NotificationHandler()
        
        //notificationHandle.showNotification(jobName: "Test", jobStatus: "Passing")
        
        let jobNames = ["jobNamed1", "jobNamed2", "jobNamed3", "jobName4", "jobNamed5", "jobNamed6"]
        notificationHandle.showNotification(jobNames: jobNames, jobStatus: "Passing")
        
        XCTAssertEqual("Passing", status1["lastJobStatus"])
    }
 
    func testJenkinsCommunicationFailing() throws {
        
        let communicationHandle = JenkinsCommuncationHandler()
        
        communicationHandle.setTestData(testData: self.testJenkinsResult2)
        
        let testJobData2 = self.prefHandler.getJobDetails(jobName: "testJob2")
        let status2 = communicationHandle.getJobResults(preferences: self.prefHandler, jobData: testJobData2)
        
        //XCTAssertEqual("Failing", status2["lastJobStatus"])
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
