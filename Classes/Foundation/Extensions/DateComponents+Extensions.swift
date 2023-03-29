/*
 DateComponents+Extensions.swift
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
//
//  DateComponentsExtensions.swift
//  radar-cli-core
//
//  Created by Alex Raftis on 9/24/18.
//

import Foundation

public extension DateComponents {
    
    // Because value(for:) return NSNotFound rather than nil.
    private func _value<T>(for component: Calendar.Component) -> T? {
        switch component {
        case .era: return era as? T
        case .year: return year as? T
        case .month: return month as? T
        case .day: return day as? T
        case .hour: return hour as? T
        case .minute: return minute as? T
        case .second: return second as? T
        case .nanosecond: return nanosecond as? T
        case .weekday: return weekday as? T
        case .weekdayOrdinal: return weekdayOrdinal as? T
        case .quarter: return quarter as? T
        case .weekOfMonth: return weekOfMonth as? T
        case .weekOfYear: return weekOfYear as? T
        case .yearForWeekOfYear: return yearForWeekOfYear as? T
        case .calendar: return calendar as? T
        case .timeZone: return timeZone as? T
        @unknown default:
            fatalError()
        }
    }
    
    private func addComponent(component: Calendar.Component, right: DateComponents) -> Int? {
        let leftValue : Int? = self._value(for: component)
        let rightValue : Int? = right._value(for: component)
        
        if leftValue != nil && rightValue != nil {
            return leftValue! + rightValue!
        } else if leftValue != nil {
            return leftValue
        } else if rightValue != nil {
            return rightValue
        }
        
        return nil
    }
    
    func dateComponents(byAdding other: DateComponents) -> DateComponents {
        return DateComponents(era: addComponent(component: .era, right: other),
                              year: addComponent(component: .year, right: other),
                              month: addComponent(component: .month, right: other),
                              day: addComponent(component: .day, right: other),
                              hour: addComponent(component: .hour, right: other),
                              minute: addComponent(component: .minute, right: other),
                              second: addComponent(component: .second, right: other),
                              nanosecond: addComponent(component: .nanosecond, right: other),
                              weekday: addComponent(component: .weekday, right: other),
                              weekdayOrdinal: addComponent(component: .weekdayOrdinal, right: other),
                              quarter: addComponent(component: .quarter, right: other),
                              weekOfMonth: addComponent(component: .weekOfMonth, right: other),
                              weekOfYear: addComponent(component: .weekOfYear, right: other),
                              yearForWeekOfYear: addComponent(component: .yearForWeekOfYear, right: other))
    }

}

extension DateComponents : AJREquatable {
    
    private func _equal(_ component : Calendar.Component, to other: DateComponents) -> Bool {
        if component == .calendar {
            return calendar == other.calendar
        } else if component == .timeZone {
            return timeZone == other.timeZone
        }
        
        var left : Int? = _value(for: component)
        var right : Int? = other._value(for: component)
        
        if left == 0 {
            left = nil
        }
        if right == 0 {
            right = nil
        }
        
        return left == right
    }
    
    // MARK: - AJREquatable

    public func isEqual(_ other: Any?) -> Bool {
        if let other = other as? DateComponents {
            return _equal(.era, to: other)
            && _equal(.year, to: other)
            && _equal(.month, to: other)
            && _equal(.day, to: other)
            && _equal(.hour, to: other)
            && _equal(.minute, to: other)
            && _equal(.second, to: other)
            && _equal(.nanosecond, to: other)
            && _equal(.weekday, to: other)
            && _equal(.weekdayOrdinal, to: other)
            && _equal(.quarter, to: other)
            && _equal(.weekOfMonth, to: other)
            && _equal(.weekOfYear, to: other)
            && _equal(.yearForWeekOfYear, to: other)
            && _equal(.calendar, to: other)
            && _equal(.timeZone, to: other)
        }
        return false
    }
    
}
