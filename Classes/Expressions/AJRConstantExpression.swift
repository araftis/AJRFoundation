/*
 ConstantExpression.swift
 AJRFoundation

 Copyright © 2021, AJ Raftis and AJRFoundation authors
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
open class AJRConstantExpression : AJRExpression {
    
    // MARK: - Properties
    
    private var isString: Bool = false
    public var _value: Any?
    public var value: Any? {
        get {
            return _value
        }
        set(newValue) {
            _value = newValue
            isString = _value is String
        }
    }
    
    // MARK: - Creation
    
    public init(value: Any? = nil) {
        super.init()
        self.value = value
    }
    
    // MARK: - Actions
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any? {
        if let constant = value as? AJRConstant {
            return constant.value
        }
        return value
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description: String {
        if let value = value {
            return isString ? "\"\(value)\"" : "\(value)"
        }
        return "nil"
    }
    
    // MARL: - Equality

    public override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRConstantExpression {
            return (super.isEqual(to: other)
                && AJRAnyEquals(value, typed.value)
            )
        }
        return false
    }
    
    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        super.init(coder:coder)
        self.value = coder.decodeObject(forKey: "value")
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(value, forKey: "value")
    }

}
