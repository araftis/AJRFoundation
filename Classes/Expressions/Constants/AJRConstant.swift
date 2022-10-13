/*
 AJRConstant.swift
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
open class AJRConstant : AJRUnaryOperator, NSCopying {

    private static var constants = [String:AJRConstant]()

    public class func registerConstant(_ constantClass : AJRConstant.Type, properties: [String:Any]) -> Void {
        if let tokens = properties["tokens"] as? [[String:Any]] {
            let constantInstance = constantClass.init()
            for token in tokens {
                if let tokenName = token["name"] as? String {
                    constants[tokenName] = constantInstance
                    AJRExpressionParser.addLiteralToken(tokenName)
                    constantInstance.append(token: tokenName)
                }
            }
        }
    }
    
    open var hashableValue : AnyHashable? { return nil }
    open var value : Any? { return hashableValue }

    public class func constant(forToken name: String) -> AJRConstant? {
        return constants[name]
    }

    // MARK: - UnaryExpression
    
    open override func performOperator(withValue object: Any?) throws -> Any? {
        return value
    }
    
    // MARK: - CustomStringConvertible
    
    open override var description: String { return "\((value == nil ? "nil" : value!))" }
    
    // MARK: - Equality
    
    open override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRConstant {
            return (super.isEqual(to: typed)
                && AJREqual(value, typed.value)
            )
        }
        return false
    }
    
    // MARK: - Hashable

    open override var hash: Int {
        if let value = value as? AnyHashable {
            var hasher = Hasher()
            value.hash(into: &hasher)
            return hasher.finalize()
        }
        return 0
    }

    /**
     Copies the receiver.

     Copies the receiver, but since we're a constant, this basically returns self.

     - parameter zone: Deprecated, don't use.

     - returns `self`
     */
    public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }

}

internal class AJRUnitTestConstant : AJRConstant {
    
    private var internalValue : Any?
    public override var value : Any? { return internalValue }

    required internal init() {
        self.internalValue = nil
        super.init()
    }
    
    internal init(value: Any?) {
        self.internalValue = value
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
