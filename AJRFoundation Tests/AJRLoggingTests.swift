//
//  AJRLoggingSwiftTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/19/19.
//

import XCTest
import AJRFoundation

class AJRLoggingSwiftTests: XCTestCase {

    func testLoggingSwiftAPI() {
        AJRLogSetGlobalLogLevel(.info)
        AJRLogResetCounts()

        AJRLog.in(domain: nil, level: .default, message: "Test Log Global/Generic\n")
        AJRLog.emergency("Test Log Emergency")
        AJRLog.alert("Test Log Alert")
        AJRLog.critical("Test Log Critical")
        AJRLog.error("Test Log Error")
        AJRLog.warning("Test Log Warning")
        AJRLog.notice("Test Log Notice")
        AJRLog.info("Test Log Info")
        AJRLog.debug("Test Log Debug")

        XCTAssert(AJRLogGetDefaultCount() == 1, "Alert count is \(AJRLogGetDefaultCount()), not 1")
        XCTAssert(AJRLogGetEmergencyCount() == 1, "Alert count is \(AJRLogGetEmergencyCount()), not 1")
        XCTAssert(AJRLogGetAlertCount() == 1, "Alert count is \(AJRLogGetAlertCount()), not 1")
        XCTAssert(AJRLogGetCriticalCount() == 1, "Critical count is \(AJRLogGetCriticalCount()), not 1")
        XCTAssert(AJRLogGetErrorCount() == 1, "Error count is \(AJRLogGetErrorCount()), not 1")
        XCTAssert(AJRLogGetWarningCount() == 1, "Warning count is \(AJRLogGetWarningCount()), not 1")
        XCTAssert(AJRLogGetNoticeCount() == 1, "Notice count is \(AJRLogGetNoticeCount()), not 1")
        XCTAssert(AJRLogGetInfoCount() == 1, "Info count is \(AJRLogGetInfoCount()), not 1")
        XCTAssert(AJRLogGetDebugCount() == 0, "Debug count is \(AJRLogGetDebugCount()), not 0")
        
        AJRLogSetGlobalLogLevel(.debug)
        XCTAssert(AJRLogGetGlobalLogLevel() == .debug)
        AJRLog.debug("Test Log Debug 2")

        XCTAssert(AJRLogGetDebugCount() == 1, "Debug count is \(AJRLogGetDebugCount()), not 1")
    }

}
