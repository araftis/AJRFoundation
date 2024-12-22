/*
 AJRLogging.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

import Foundation

public struct AJRLog {
    
    public static func `in`(domain: AJRLoggingDomain?, level: AJRLogLevel = .info, message: @autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, level) {
            AJRSimpleLog(domain, level, message())
        }
    }

    public static func `in`(domain: AJRLoggingDomain?, level: AJRLogLevel = .info, format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, level) {
            AJRSimpleLog(domain, level, String(format: format, arguments: arguments))
        }
    }

    public static func emergency(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .emergency) {
            AJRSimpleLog(domain, .emergency, message())
        }
    }
    
    public static func emergency(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .emergency) {
            AJRSimpleLog(domain, .emergency, String(format: format, arguments: arguments))
        }
    }

    public static func alert(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .alert) {
            AJRSimpleLog(domain, .alert, message())
        }
    }
    
    public static func alert(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .alert) {
            AJRSimpleLog(domain, .alert, String(format: format, arguments: arguments))
        }
    }

    public static func critical(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .critical) {
            AJRSimpleLog(domain, .critical, message())
        }
    }
    
    public static func critical(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .critical) {
            AJRSimpleLog(domain, .critical, String(format: format, arguments: arguments))
        }
    }

    public static func error(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .error) {
            AJRSimpleLog(domain, .error, message())
        }
    }
    
    public static func error(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .error) {
            AJRSimpleLog(domain, .error, String(format: format, arguments: arguments))
        }
    }

    public static func warning(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .warning) {
            AJRSimpleLog(domain, .warning, message())
        }
    }

    public static func warning(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .warning) {
            AJRSimpleLog(domain, .warning, String(format: format, arguments: arguments))
        }
    }

    public static func notice(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .notice) {
            AJRSimpleLog(domain, .notice, message())
        }
    }
    
    public static func notice(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .notice) {
            AJRSimpleLog(domain, .notice, String(format: format, arguments: arguments))
        }
    }

    public static func info(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .info) {
            AJRSimpleLog(domain, .info, message())
        }
    }
    
    public static func info(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .info) {
            AJRSimpleLog(domain, .info, String(format: format, arguments: arguments))
        }
    }

    public static func debug(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), _ message:@autoclosure () -> String) -> Void {
        if AJRLogShouldOutputForDomain(domain, .debug) {
            AJRSimpleLog(domain, .debug, message())
        }
    }

    public static func debug(in domain:AJRLoggingDomain=AJRLoggingDomain(#function), format: String, _ arguments: CVarArg...) -> Void {
        if AJRLogShouldOutputForDomain(domain, .debug) {
            AJRSimpleLog(domain, .debug, String(format: format, arguments: arguments))
        }
    }

}
