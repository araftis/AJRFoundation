/*
 AJRSimpleExpression.swift
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
//  AJRSimpleExpression.swift.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJRSimpleExpression : AJROperatorExpression {
    
    public var left: Any?
    public var right: Any?
    
    required public init() {
        super.init()
    }

    public init(left: Any?, operator anOperator: AJROperator, right: Any?) {
        super.init(anOperator)
        self.left = left
        self.right = right
    }

    public class func expression(left: Any?, operator anOperator: AJROperator, right: Any?) -> AJRSimpleExpression {
        return AJRSimpleExpression(left: left, operator: anOperator, right: right)
    }
    
    // MARK: - Actions
    
    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        let left = try AJRExpression.evaluate(value: self.left, with: context)
        let right = try AJRExpression.evaluate(value: self.right, with: context)
        return try self.operator.performOperator(left: left, right: right, context: context) ?? NSNull()
    }
    
    // MARK: - CustomStringConvertible
    
    public override var description : String {
        return "(\(left ?? "nil") \(self.operator.preferredToken) \(right ?? "nil"))"
    }

    @objc
    public override func isEqual(_ other: Any?) -> Bool {
        if let typed = other as? AJRSimpleExpression {
            return (super.isEqual(other)
                && AJRAnyEquals(left, typed.left)
                && AJRAnyEquals(right, typed.right)
            )
        }
        return false
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        self.left = coder.decodeObject(forKey: "left")
        self.right = coder.decodeObject(forKey: "right")
        super.init(coder: coder)
    }

    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(left, forKey:"left")
        coder.encode(right, forKey:"right")
    }

    // MARK: - AJRXMLCoding

    public override func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "left") { self.left = $0 }
        coder.decodeObject(forKey: "right") { self.right = $0 }
    }

    public override func encode(with coder: AJRXMLCoder) {
        coder.encode(left, forKey: "left")
        coder.encode(right, forKey: "right")
    }

}
