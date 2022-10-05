//
//  AJROperatorExpression.swift
//  radar-core
//
//  Created by Alex Raftis on 8/13/18.
//

import Foundation

public class AJROperatorExpression : AJRExpression {
    
    public var `operator`: AJROperator
    
    public init(_ anOperator: AJROperator) {
        self.operator = anOperator
    }
    
    public override func isEqual(to other: Any) -> Bool {
        if let other = other as? AJROperatorExpression {
            return (super.isEqual(to: other)
                && self.operator == other.operator)
        }
        return false
    }
    
}
