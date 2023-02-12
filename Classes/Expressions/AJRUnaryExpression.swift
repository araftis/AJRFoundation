/*
 AJRUnaryExpression.swift
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
//  AJRUnaryExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJRUnaryExpression : AJROperatorExpression {

    public var value : Any?
    
    // MARK: - Creation

    required public init() {
        super.init()
    }
    
    public init(value: Any?, operator anOperator: AJROperator) {
        assert(anOperator is AJRUnaryOperator || anOperator.canActAsUnary)
        super.init(anOperator)
        self.value = value
    }
    
    // MARK: - Actions
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        let value = try AJRExpression.evaluate(value: self.value, with: context)
        return try self.operator.performOperator(value: value, context: context) ?? NSNull()
    }
    
    // MARK: - NSObject
    
    public override var description : String {
        return "\(self.operator.preferredToken)\(value ?? "nil")"
    }
    
    // MARK: - Equatable
    
    public override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJRUnaryExpression {
            return (super.isEqual(to: other)
                && AJREqual(self.value, other.value)
            )
        }
        return false
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let value = coder.decodeObject(forKey: "value") as? AJREvaluation {
            self.value = value
        } else {
            return nil
        }
        super.init(coder: coder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(value, forKey:"value")
    }

    // MARK: - AJRXMLCoding

    public override func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "value") { self.value = $0 }
    }

    public override func encode(with coder: AJRXMLCoder) {
        coder.encode(value, forKey: "value")
    }

}
