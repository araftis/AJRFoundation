//
//  NSObject+AJRUserInfo.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 7/8/26.
//

import Foundation

public struct AJRUserInfoKey<Value>: RawRepresentable, Hashable, Sendable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension NSObject {

    public class func classObject<Value>(forKey key: AJRUserInfoKey<Value>) -> Value? {
        return _classObject(forKey: key.rawValue) as? Value
    }

    public class func setClassObject<Value>(_ value: Value?, forKey key: AJRUserInfoKey<Value>) {
        _setClassObject(value, forKey: key.rawValue)
    }

    public func instanceObject<Value>(forKey key: AJRUserInfoKey<Value>) -> Value? {
        return _instanceObject(forKey: key.rawValue) as? Value
    }

    public func setInstanceObject<Value>(_ value: Value?, forKey key: AJRUserInfoKey<Value>) {
        _setInstanceObject(value, forKey: key.rawValue)
    }

}

