//
//  SubtractOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRSubtractOperator : AJROperator, AJRIntegerOperator, AJRFloatingPointOperator, AJRIntegerUnaryOperator, AJRFloatingPointUnaryOperator, AJRDateOperator, AJRCollectionOperator {
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left - right
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left - right
    }
    
    public func performIntegerOperator(value: Int) throws -> Any? {
        return -value
    }
    
    public func performFloatingPointOperator(value: Double) throws -> Any? {
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
    
    public func performDateOperator(left: AJRTimeZoneDate, right: AJRTimeZoneDate) throws -> Any? {
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: left, to: right)
    }
    
    public func performDateOperator(left: AJRTimeZoneDate, right: DateComponents) throws -> Any? {
        return Calendar.current.date(byAdding: invertComponents(right), to: left, wrappingComponents: false)
    }
    
    public func performDateOperator(left: DateComponents, right: AJRTimeZoneDate) throws -> Any? {
        let rightComponents = Calendar(identifier: .gregorian).dateComponents(from: right)
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: left, to: rightComponents)
    }
    
    public func performDateOperator(left: DateComponents, right: DateComponents) throws -> Any? {
        return Calendar(identifier: .gregorian).dateComponents([.year, .month, .day, .hour, .minute, .second], from: right, to: left)
    }

    public func performCollectionOperator(left: (any AJRCollection)?, right: (any AJRCollection)?) throws -> Any? {
        if let left = left {
            if let right = right {
                return left.subtract(right)
            }
            return left
        }
        return nil
    }
    
}
