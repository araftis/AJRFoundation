//
//  AJRKeyExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/14/18.
//

import Foundation

public class AJRKeyExpression : AJRExpression {

    // MARK: - Creation

    public var keyPath: String
    
    public init(keyPath: String) {
        self.keyPath = keyPath
    }

    // MARK: - Actions

    public override func evaluate(withObject object: Any?) throws -> Any? {
        return getValue(forKeyPath: keyPath, on: object)
    }

    // MARK: - NSObject

    public override var description: String { return keyPath }

    // MARK: - Equality
    
    public override func isEqual(to other: Any) -> Bool {
        if let typed = other as? AJRKeyExpression {
            return (super.isEqual(to: other)
                && keyPath == typed.keyPath)
        }
        return false
    }

}
