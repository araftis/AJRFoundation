/*
 AJROperatorExpression.swift
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
//  AJROperatorExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

@objcMembers
public class AJROperatorExpression : AJRExpression {
    
    public var `operator`: AJROperator!
    
    required public init() {
        super.init()
    }

    public init(_ anOperator: AJROperator) {
        self.operator = anOperator
        super.init()
    }

    @objc
    open override func isEqual(to other: Any?) -> Bool {
        if let other = other as? AJROperatorExpression {
            return (super.isEqual(to: other)
                && AJRAnyEquals(self.operator, other.operator))
        }
        return false
    }
    
    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let op = coder.decodeObject(forKey: "operator") as? AJROperator {
            self.operator = op
        } else {
            return nil
        }
        super.init(coder: coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(`operator`, forKey: "operator")
    }

    // MARK: - AJRXMLCoding

    public override func decode(with coder: AJRXMLCoder) {
        coder.decodeObject(forKey: "operator") { value in
            if let value = value as? AJROperator {
                self.operator = value
            }
        }
    }

    public override func encode(with coder: AJRXMLCoder) {
        coder.encode(`operator`, forKey: "operator")
    }

}
