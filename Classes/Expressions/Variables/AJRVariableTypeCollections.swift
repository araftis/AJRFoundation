/*
 AJRVariableTypeCollections.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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
                // NOTE: We can't "force" these, because forcing will convert something like "5" into "[5]", which will then make a collection operation valid for non-collections, whih isn't what we want.
                let leftCollection : (any AJRCollection)? = try Conversion.valueAsCollection(left, force: false)
                let rightCollection : (any AJRCollection)? = try Conversion.valueAsCollection(right, force: false)
                consumed = true
                return try op.performCollectionOperator(left: leftCollection, right: rightCollection)
            } catch (ValueConversionError.valueIsNotACollection(_)) {
                // When this happens, we can't actually do our thing.
                return nil
            }
        }
        return nil
    }

    public override func createDefaultValue() -> Any? {
        return Array<Any>()
    }

    open override func value(from string: String) throws -> Any? {
        throw ValueConversionError.valueIsNotACollection("Cannot convert strings to collections. This should probably be \"fixed\".")
    }

}

@objcMembers
open class AJRVariableTypeSet : AJRVariableType {
    // NOTE: Let AJRVariableTypeArray deal with operations, since it's all the same code for each collection type.

    public override func createDefaultValue() -> Any? {
        return Set<AnyHashable>()
    }

    open override func value(from string: String) throws -> Any? {
        throw ValueConversionError.valueIsNotACollection("Cannot convert strings to collections. This should probably be \"fixed\".")
    }

}

@objcMembers
open class AJRVariableTypeDictionary : AJRVariableType {
    // NOTE: Let AJRVariableTypeArray deal with operations, since it's all the same code for each collection type.

    public override func createDefaultValue() -> Any? {
        return Dictionary<AnyHashable, Any>()
    }

    open override func value(from string: String) throws -> Any? {
        throw ValueConversionError.valueIsNotACollection("Cannot convert strings to collections. This should probably be \"fixed\".")
    }

}

public extension AJRVariableType {

    static let array = AJRVariableType.variableType(for: AJRVariableTypeArray.self)!
    static let set = AJRVariableType.variableType(for: AJRVariableTypeSet.self)!
    static let dictionary = AJRVariableType.variableType(for: AJRVariableTypeDictionary.self)!
    
}
