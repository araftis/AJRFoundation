/*
 AJRExpression.swift
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

public enum AJRExpressionError : Error {

    case valueIsNotANumber(String)
    case valueIsNotABool(String)
    case unimplementedMethod(String)

}

@objc
open class AJRExpression: NSObject, AJREquatable {

    // MARK: - Properties

    public var protected = false
    internal var dateTimeZoneMap = [Date: TimeZone]()

    // MARK: - Creation

    public class func expression(string: String) throws -> AJRExpression {
        return try AJRExpressionParser(string: string).expression()
    }

    public class func expression(format: String, _ arguments: Any?...) throws -> AJRExpression {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    // MARK: - Actions

    public class func evaluate(value: Any?, withObject object: Any?) throws -> Any? {
        var returnValue = value
        while returnValue is AJRExpression {
            returnValue = try (returnValue! as! AJRExpression).evaluate(withObject: object)
        }
        return returnValue
    }

    public func evaluate(withObject object: Any? = nil) throws -> Any? {
        throw AJRExpressionError.unimplementedMethod("Abstract method \(type(of:self)).\(#function) should be implemented")
    }

    // MARK: - Equatable

    public func isEqual(to other: Any) -> Bool {
        if let typed = other as? AJRExpression {
            return AJREqual(protected, typed.protected)
        }
        return false
    }

    public static func == (lhs: AJRExpression, rhs: AJRExpression) -> Bool {
        return lhs.isEqual(to: rhs)
    }

    // MARK: - Hashable

    public override var hash: Int {
        return protected ? 1 : 0
    }

    // MARK: - Utilities

    /*! Recursive evaluates value until we reach something that doesn't evaluate to an expression. */
    public class func value(_ valueIn: Any?, withObject object: Any? = nil) throws -> Any? {
        var value = valueIn
        while value is AJRExpression {
            value = try (value! as! AJRExpression).evaluate(withObject: object)
        }
        return value
    }

    public class func valueAsCollection(_ valueIn: Any?, withObject object: Any? = nil) throws -> AJRUntypedCollection? {
        // Iterate an expression values until we get a basic value of some sort returned.
        if var returnValue = try value(valueIn, withObject: object) {
            // Now see if we already have a collection class. If we do, we can just return it.
            if !(returnValue is AJRUntypedCollection) {
                // Value isn't a collection so make it a collection.
                returnValue = Set<AnyHashable>([returnValue as! AnyHashable])
            }

            return returnValue as? AJRUntypedCollection
        }
        return nil
    }

    public class func valueAsBool(_ valueIn: Any?, withObject object: Any? = nil) throws -> Bool {
        return try Conversion.valueAsBool(try value(valueIn, withObject: object))
    }

    public class func valueAsInteger<T: BinaryInteger>(_ valueIn: Any?, withObject object: Any? = nil) throws -> T {
        return try Conversion.valueAsInteger(try value(valueIn, withObject: object))
    }

    public class func valueAsFloat<T: BinaryFloatingPoint>(_ valueIn: Any?, withObject object: Any? = nil) throws -> T {
        return try Conversion.valueAsFloatingPoint(try value(valueIn, withObject: object))
    }

    public class func valueAsString(_ valueIn: Any?, withObject object: Any? = nil) throws -> String {
        return try Conversion.valueAsString(try value(valueIn, withObject: object))
    }

    public class func valueAsDate(_ valueIn: Any?, withObject object: Any? = nil) throws -> AJRTimeZoneDate? {
        return try Conversion.valueAsTimeZoneDate(try value(valueIn, withObject: object))
    }

    public class func valueAsDateComponents(_ valueIn: Any?, withObject object: Any? = nil) throws -> DateComponents? {
        return try Conversion.valueAsDateComponents(try value(valueIn, withObject: object))
    }

    // MARK: - CustomStringConvertible

    public override var description : String { return "" }

}
