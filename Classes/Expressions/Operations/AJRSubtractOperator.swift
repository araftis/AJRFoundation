//
//  SubtractOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRSubtractOperator : AJROperator, AJRIntOperator, AJRDoubleOperator, AJRIntUnaryOperator, AJRDoubleUnaryOperator, AJRDateOperator, AJRCollectionOperator {
    
    public func performIntOperator(withLeft left: Int, andRight right: Int) throws -> Any? {
        return left - right
    }
    
    public func performDoubleOperator(withLeft left: Double, andRight right: Double) throws -> Any? {
        return left - right
    }
    
    public func performIntOperator(withValue value: Int) throws -> Any? {
        return -value
    }
    
    public func performDoubleOperator(withValue value: Double) throws -> Any? {
        return -value
    }

    private func invertComponents(_ components: DateComponents) -> DateComponents {
        return DateComponents(year: components.year == nil ? nil : -components.year!,
                              month: components.month == nil ? nil : -components.month!,
                              day: components.day == nil ? nil : -components.day!,
                              hour: components.hour == nil ? nil : -components.hour!,
                              minute: components.minute == nil ? nil : -components.minute!,
                              second: components.second == nil ? nil : -components.second!)
    }
    
    public func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: AJRTimeZoneDate) throws -> Any? {
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: left, to: right)
    }
    
    public func performDateOperator(withLeft left: AJRTimeZoneDate, andRight right: DateComponents) throws -> Any? {
        return Calendar.current.date(byAdding: invertComponents(right), to: left, wrappingComponents: false)
    }
    
    public func performDateOperator(withLeft left: DateComponents, andRight right: AJRTimeZoneDate) throws -> Any? {
        let rightComponents = Calendar(identifier: .gregorian).dateComponents(from: right)
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: left, to: rightComponents)
    }
    
    public func performDateOperator(withLeft left: DateComponents, andRight right: DateComponents) throws -> Any? {
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: right, to: left)
    }

    public func performCollectionOperator(withLeft left: (any AJRCollection)?, andRight right: (any AJRCollection)?) throws -> Any? {
        if let left = left {
            if let right = right {
                return left.subtract(right)
            }
            return left
        }
        return nil
    }
    
}
