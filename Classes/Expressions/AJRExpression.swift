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
    case invalidParameter(String)

}

@objcMembers
open class AJRExpression: NSObject, AJREquatable, NSCoding {

    // MARK: - Properties

    public var protected = false
    internal var dateTimeZoneMap = [Date: TimeZone]()

    // MARK: - Creation

    // Bring this back if I decide to support property list encoding, but right now, I'm not inclined to do so.
//    @objc(expressionForObject:error:)
//    public class func expression(object: Any) throws -> AJRExpression {
//        if let string = object as? String {
//            return try expression(string: string)
//        } else if let dictionary = object as? Dictionary<AnyHashable,Any> {
//            return try create(withPropertyListValue: dictionary) as! AJRExpression
//        }
//        throw AJRExpressionError.invalidParameter("The input to expression(object:) must be a String or a Dictionary.")
//    }

    @objc(expressionWithString:error:)
    public class func expression(string: String) throws -> AJRExpression {
        return try AJRExpressionParser(string: string).expression()
    }

    @objc(expressionWithFormat:arguments:error:)
    public class func expression(format: String, _ arguments: [Any]) throws -> AJRExpression {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    public class func expression(format: String, _ arguments: Any?...) throws -> AJRExpression {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    public override init() {
        self.protected = false
    }

    private init(protected: Bool) {
        self.protected = protected
    }

    // MARK: - Actions

    public class func evaluate(value: Any?, withObject object: Any?) throws -> Any? {
        var returnValue = value
        while returnValue is AJRExpression {
            returnValue = try (returnValue! as! AJRExpression).evaluate(with: object)
        }
        return returnValue
    }

    /**
     Evaluates the receiver and returns the result.

     This method is primarily meant to be called from Obj-C, and is a little jenky, because we break the standard convention here, just a little. Normally, if a method has an error parameter and returns nil, then that means an error occurred. However, for our purposes, we could evaluate to nil, as that's perfectly acceptable. As such, unlike most calls of this pattern, we always initialize `errorIO` to nil, and then initialize it with any error that occurs.

     - parameter object: The "root" object of the evaluation. This is messaged to resolve key paths.
     - parameter errorIO: A pointer to an NSError object. It may be nil.
     */
    @objc(evaluateWithObject:error:)
    public func evaluate(withObject object: Any? = nil, error errorIO: UnsafeMutablePointer<NSError?>?) -> Any? {
        errorIO?.pointee = nil
        do {
            return try evaluate(with: object)
        } catch {
            errorIO?.pointee = error as NSError
        }
        return nil
    }

    public func evaluate(with object: Any? = nil) throws -> Any? {
        throw AJRExpressionError.unimplementedMethod("Abstract method \(type(of:self)).\(#function) should be implemented")
    }

    // MARK: - Equatable

    @objc
    public override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRExpression {
            return AJRAnyEquals(protected, typed.protected)
        }
        return false
    }

    @objc
    public override func isEqual(_ object: Any?) -> Bool {
        return isEqual(to: object)
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
            value = try (value! as! AJRExpression).evaluate(with: object)
        }
        return value
    }

    public class func valueAsCollection(_ valueIn: Any?, withObject object: Any? = nil) throws -> (any AJRCollection)? {
        // Iterate an expression values until we get a basic value of some sort returned.
        if var returnValue = try value(valueIn, withObject: object) {
            // Now see if we already have a collection class. If we do, we can just return it.
            if !(returnValue is (any AJRCollection)) {
                // Value isn't a collection so make it a collection.
                returnValue = Set<AnyHashable>([returnValue as! AnyHashable])
            }

            return returnValue as? (any AJRCollection)
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

    // I'm not sure these are necessary any longer.
//    + (AJRExpression *)expressionForDictionary:(NSDictionary *)dictionary error:(NSError **)error {
//        return [[self alloc] initWithPropertyListValue:dictionary error:error];
//    }
//
//    + (AJRExpression *)expressionForObject:(id)anObject error:(NSError **)error {
//        if ([anObject isKindOfClass:[NSDictionary class]]) {
//            return [self expressionForDictionary:anObject error:error];
//        } else {
//            // Couldn't make a dictionary, so it must be a string.
//            return [self expressionWithString:[anObject description] error:error];
//        }
//    }

    public var propertyListValue : Any {
        return ["type": NSStringFromClass(Self.self), "protected": protected];
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        self.protected = coder.decodeBool(forKey: "protected")
    }

    public func encode(with coder: NSCoder) {
        coder.encode(protected, forKey: "protected")
    }


}
