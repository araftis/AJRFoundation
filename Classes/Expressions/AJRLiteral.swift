/*
AJRLiteral.swift
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
open class AJRLiteral : NSObject, AJREvaluation, NSCoding, AJREquatable, AJRXMLCoding {

    open var name : String!

    @objc(literalWithName:)
    public class func literal(with name: String) -> AJRLiteral {
        return AJRLiteral(name: name)
    }

    required public override init() {
        super.init()
    }

    public init(name: String) {
        self.name = name
    }

    // MARK: - AJREquatable

    open override func isEqual(to object: Any?) -> Bool {
        if let object = object as? AJRLiteral {
            return AJRAnyEquals(name, object.name)
        }
        return false
    }

    open override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
    }

    // MARK: - Hashable

    open override var hash: Int {
        return name.hash
    }

    // MARK: - CustomStringConvertible

    open override var description: String {
        return name
    }

    // MARK: - AJREvaluation

    open func evaluate(with context: AJREvaluationContext) throws -> Any {
        // First, let's check and see if we have a something defined for us in context.
        if let symbol = context.symbol(named: name) {
            return try AJRExpression.value(symbol, with: context) ?? NSNull()
        } else {
            // We don't define this as a symbol, so we treat it as a key path and resolve via context's rootObject.
            return getValue(forKeyPath: name, on: context.rootObject) ?? NSNull()
        }
    }

    // MARK: - NSCoding

    required public init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") ?? "<undefined>"
    }

    open func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
    }

    // MARK: - AJRXMLCoding

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeString(forKey: "name") { self.name = $0 }
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(name, forKey: "name")
    }

    // MARK: - NSCopying

    open func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of:self).init()

        copy.name = name

        return copy
    }

}
