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
    
    public func isEqual(to other: Any) -> Bool {
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
