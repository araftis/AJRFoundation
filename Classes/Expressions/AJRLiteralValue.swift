/*
 AJRLiteralValue.swift
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

import Foundation

@objcMembers
open class AJRLiteralValue : NSObject, AJREvaluation, AJREquatable, NSCoding, AJRXMLCoding {
    
    // MARK: - Properties
    
    public var value: Any?
    
    // MARK: - Creation

    required public override init() {
        super.init()
    }
    
    public init(value: Any? = nil) {
        self.value = value
        super.init()
    }
    
    // MARK: - Actions
    
    public func evaluate(with context: AJREvaluationContext) throws -> Any {
        if let constant = value as? AJRConstant {
            return constant.value ?? NSNull()
        }
        return value ?? NSNull()
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description: String {
        if let value = value {
            return (value is String) ? "\"\(value)\"" : "\(value)"
        }
        return "nil"
    }
    
    // MARK: - Equality

    public override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRLiteralValue {
            return AJRAnyEquals(value, typed.value)
        }
        return false
    }

    public override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }

    // MARK: - Hashable

    open override var hash: Int {
        if let value = value as? AnyHashable {
            return value.hashValue
        }
        if let value = value {
            return String(describing: value).hashValue
        }
        return NSNull().hashValue
    }
    
    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        self.value = coder.decodeObject(forKey: "value")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(value, forKey: "value")
    }

    // MARK: - AJRXMLCoding

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "value") { value in
            self.value = value
        }
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(value, forKey: "value")
    }

    // MARK: - NSCopying

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()

        if let copyable = value as? NSCopying {
            copy.value = copyable.copy(with: zone)
        } else {
            copy.value = value
        }

        return copy
    }

}
