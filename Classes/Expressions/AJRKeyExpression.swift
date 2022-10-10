//
//  AJRKeyExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/14/18.
//

import Foundation

@objcMembers
public class AJRKeyExpression : AJRExpression {

    // MARK: - Creation

    public var keyPath: String
    
    public init(keyPath: String) {
        self.keyPath = keyPath
        super.init()
    }

    // MARK: - Actions

    public override func evaluate(with object: Any?) throws -> Any? {
        return getValue(forKeyPath: keyPath, on: object)
    }

    // MARK: - NSObject

    public override var description: String { return keyPath }

    // MARK: - Equality
    
    public override func isEqual(to other: Any?) -> Bool {
        if let typed = other as? AJRKeyExpression {
            return (super.isEqual(to: other)
                && keyPath == typed.keyPath)
        }
        return false
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let key = coder.decodeObject(forKey: "key") as? String {
            self.keyPath = key
        } else {
            return nil
        }
        super.init(coder: coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(keyPath, forKey: "key")
    }

}
