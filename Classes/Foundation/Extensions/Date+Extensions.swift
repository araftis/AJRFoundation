/*
 Date+Extensions.swift
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

public enum DateError : Error {
    case invalidFormat(String)
}

public extension Date {

    init(utc: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let newDate = formatter.date(from: utc) {
            self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let newDate = formatter.date(from: utc) {
                self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
            } else {
                formatter.dateFormat = "yyyy-MM-dd"
                if let newDate = formatter.date(from: utc) {
                    self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
                } else {
                    throw DateError.invalidFormat("Input isn't valid UTC: \(utc)")
                }
            }
        }
    }

    init(utc: String, timeZone: inout TimeZone?) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let newDate = formatter.date(from: utc) {
            if utc.count > 5 {
                let tzSubstring = utc[utc.index(utc.endIndex, offsetBy: -5) ..< utc.endIndex]
                if let offset = Int(tzSubstring) {
                    timeZone = TimeZone(secondsFromGMT: ((offset / 100) * 60 * 60) + ((offset % 100) * 60))
                }
            }
            self.init(timeIntervalSinceReferenceDate: newDate.timeIntervalSinceReferenceDate)
        } else {
            try self.init(utc: utc)
            timeZone = TimeZone.current
        }
    }

    static func dateForStartOfDayLocalTime() -> Date {
        return Calendar.current.startOfDay(for:Date())
    }

}
