/*
 AJRAddOperator.swift
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
//
//  AndOperator.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
open class AJRAddOperator : AJROperator, AJRStringOperator, AJRIntegerOperator, AJRFloatingPointOperator, AJRDateOperator {

    public func performStringOperator(left: String?, right: String?) throws -> Any? {
        if left == nil {
            return right
        }
        if right == nil {
            return left
        }
        return left! + right!
    }
    
    public func performIntegerOperator(left: Int, right: Int) throws -> Any? {
        return left + right
    }
    
    public func performFloatingPointOperator(left: Double, right: Double) throws -> Any? {
        return left + right
    }
    
    public override func performOperator(value: Any?, context: AJREvaluationContext) throws -> Any? {
        return value
    }
    
    public func performDateOperator(left: AJRTimeZoneDate, right: AJRTimeZoneDate) throws -> Any? {
        throw AJROperatorError.invalidInput("Only date components can be added to dates.")
    }
    
    public func performDateOperator(left: AJRTimeZoneDate, right: DateComponents) throws -> Any? {
        return Calendar.current.date(byAdding: right, to: left, wrappingComponents: true)
    }
    
    public func performDateOperator(left: DateComponents, right: AJRTimeZoneDate) throws -> Any? {
        return Calendar.current.date(byAdding: left, to: right, wrappingComponents: true)
    }
    
    public func performDateOperator(left: DateComponents, right: DateComponents) throws -> Any? {
        return left.dateComponents(byAdding: right)
    }
    
}
