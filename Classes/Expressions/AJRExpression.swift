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
open class AJRExpression: NSObject, AJREquatable, NSCoding, AJREvaluation, AJRXMLCoding {

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
    public class func expression(string: String) throws -> AJREvaluation {
        return try AJRExpressionParser(string: string).expression()
    }

    @objc(expressionWithFormat:arguments:error:)
    public class func expression(format: String, _ arguments: [Any]) throws -> AJREvaluation {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    public class func expression(format: String, _ arguments: Any?...) throws -> AJREvaluation {
        return try AJRExpressionParser(format: format, arguments).expression()
    }

    required public override init() {
        self.protected = false
    }
    
    private init(protected: Bool) {
        self.protected = protected
    }

    // MARK: - Actions

    public func evaluate(with context: AJREvaluationContext) throws -> Any {
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
    public class func value(_ valueIn: Any?, with context: AJREvaluationContext) throws -> Any? {
        var value = valueIn
        while value is AJREvaluation {
            value = try (value! as! AJREvaluation).evaluate(with: context)
        }
        if let set = value as? NSSet {
            // This is necessary because the NSSet intermediate in the bridge doesn't implement Collection, which means it can't implement AJRCollection, so we have to convert it to Set.
            var temp = Set<AnyHashable>()
            for object in set {
                // It should be safe to force this coersion, because anything in an NSSet will be Hashable.
                temp.insert(object as! (AnyHashable))
            }
            value = temp
        } else if let dictionary = value as? NSDictionary {
            // This is necessary because the NSSet intermediate in the bridge doesn't implement Collection, which means it can't implement AJRCollection, so we have to convert it to Set.
            var temp = Dictionary<AnyHashable,Any>()
            for (key, object) in dictionary {
                // It should be safe to force this coersion, because any key in a dictionary should be Hashable.
                temp[key as! AnyHashable] = object
            }
            value = temp
        }
        return value
    }

    public class func valueAsCollection(_ valueIn: Any?, with context: AJREvaluationContext) throws -> (any AJRCollection)? {
        // Iterate an expression values until we get a basic value of some sort returned.
        if var returnValue = try value(valueIn, with: context) {
            // Now see if we already have a collection class. If we do, we can just return it.
            if !(returnValue is (any AJRCollection)) {
                // Value isn't a collection so make it a collection.
                returnValue = Set<AnyHashable>([returnValue as! AnyHashable])
            }

            return returnValue as? (any AJRCollection)
        }
        return nil
    }

    public class func valueAsBool(_ valueIn: Any?, with context: AJREvaluationContext) throws -> Bool {
        return try Conversion.valueAsBool(try value(valueIn, with: context))
    }

    public class func valueAsInteger<T: BinaryInteger>(_ valueIn: Any?, with context: AJREvaluationContext) throws -> T {
        return try Conversion.valueAsInteger(try value(valueIn, with: context))
    }

    public class func valueAsFloat<T: BinaryFloatingPoint>(_ valueIn: Any?, with context: AJREvaluationContext) throws -> T {
        return try Conversion.valueAsFloatingPoint(try value(valueIn, with: context))
    }

    public class func valueAsString(_ valueIn: Any?, with context: AJREvaluationContext) throws -> String {
        return try Conversion.valueAsString(try value(valueIn, with: context))
    }

    public class func valueAsDate(_ valueIn: Any?, with context: AJREvaluationContext) throws -> AJRTimeZoneDate? {
        return try Conversion.valueAsTimeZoneDate(try value(valueIn, with: context))
    }

    public class func valueAsDateComponents(_ valueIn: Any?, with context: AJREvaluationContext) throws -> DateComponents? {
        return try Conversion.valueAsDateComponents(try value(valueIn, with: context))
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

    // MARK: - AJRXMLCoding

    public func decode(with coder: AJRXMLCoder) {
        coder.decodeBool(forKey: "protected") { value in
            self.protected = value
        }
    }

    public func encode(with coder: AJRXMLCoder) {
        coder.encode(protected, forKey: "protected")
    }

}
