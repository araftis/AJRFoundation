/*
AJRLoggingTests.swift
AJRFoundation

Copyright © 2022, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

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
