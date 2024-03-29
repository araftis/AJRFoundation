/*
 AJRSubtractOperator.swift
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
