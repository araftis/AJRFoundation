//
//  AJRStringEncodable.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 4/29/23.
//

import Foundation

// MARK: AJRStringEncodable

/**
 Defines a protocol for converting values to and from a string. This can then be used in a number of places. For example, say you're writing values to a file. You could require that the values be AJRStringEncodable, which means that the vales can write themselves in a human readable form as well as recreate themselves from a human readable form.

 Note that the form doesn't necessarily have to be easily human readable, but it should be representable in UTF-8 and avoid using things like control characters.
 */
public protocol AJRStringEncodable {

    var stringEncodableValue: String { get }
    init?(stringEncodableValue: String)

}

extension String : AJRStringEncodable {

    public var stringEncodableValue: String {
        return self
    }

    public init?(stringEncodableValue: String) {
        self.init(stringEncodableValue)
    }

}

// MARK: Integer Tyeps

extension SignedInteger {

    public var stringEncodableValue: String {
        return String(self)
    }

    public init?(stringEncodableValue: String) {
        var isNegative = false
        var value = Self.init()
        if stringEncodableValue.isEmpty {
            return nil
        }
        for c in stringEncodableValue {
            if let v = c.wholeNumberValue {
                value = value * 10 + Self(v)
            } else if c == "-" {
                // We only allow the negative sign on the front.
                if isNegative || value != 0 {
                    return nil
                }
                isNegative = true
            } else {
                // We're going to be string here, because we should only be passed as input what we generate as output.
                return nil
            }
        }
        if isNegative {
            self.init(-value)
        } else {
            self.init(value)
        }
    }

}

extension UnsignedInteger {

    public var stringEncodableValue: String {
        return String(self)
    }

    public init?(stringEncodableValue: String) {
        var value = Self.init()
        if stringEncodableValue.isEmpty {
            return nil
        }
        for c in stringEncodableValue {
            if let v = c.wholeNumberValue {
                value = value * 10 + Self(v)
            } else {
                // We're going to be string here, because we should only be passed as input what we generate as output.
                return nil
            }
        }
        self.init(value)
    }

}

extension Int : AJRStringEncodable { }
extension Int8 : AJRStringEncodable { }
extension Int16 : AJRStringEncodable { }
extension Int32 : AJRStringEncodable { }
extension Int64 : AJRStringEncodable { }
extension UInt : AJRStringEncodable { }
extension UInt8 : AJRStringEncodable { }
extension UInt16 : AJRStringEncodable { }
extension UInt32 : AJRStringEncodable { }
extension UInt64 : AJRStringEncodable { }
