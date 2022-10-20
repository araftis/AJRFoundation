//
//  AJRVariableTypeCollections.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

public protocol AJRCollectionOperator {
    func performCollectionOperator(left: (any AJRCollection)?, right: (any AJRCollection)?) throws -> Any?
}

/**
 Deals with array operations.

 __NOTE:__ We're going to have this be the work horse, even though we also define a set and dictionary type.
 */
@objcMembers
open class AJRVariableTypeArray : AJRVariableType {

    open override func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        if let op = `operator` as? AJRCollectionOperator {
            do {
                let leftCollection : (any AJRCollection)? = try Conversion.valueAsCollection(left, force: true)
                let rightCollection : (any AJRCollection)? = try Conversion.valueAsCollection(right, force: true)
                consumed = true
                return try op.performCollectionOperator(left: leftCollection, right: rightCollection)
            } catch (ValueConversionError.valueIsNotACollection(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }

}

@objcMembers
open class AJRVariableTypeSet : AJRVariableType {
    // NOTE: Let AJRVariableTypeArray deal with operations, since it's all the same code for each collection type.
}

@objcMembers
open class AJRVariableTypeDictionary : AJRVariableType {
    // NOTE: Let AJRVariableTypeArray deal with operations, since it's all the same code for each collection type.
}
