//
//  AJREditableFriend.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 2/16/23.
//

import Foundation

/**
 This property wrapper manages an editable object contained by an editable object. In this circumstance, you'd like the "friend" to also be added to the owner's editing context, as well as observed by owner so that changes to the "friend" can be propagated to the owner's observers.

 */
@propertyWrapper
open class AJREditableFriend<EditableValue: AJREditableObject> : AJREditObserver {

    private var value : EditableValue? = nil {
        willSet {
            value?.removeObserver(self)
        }
        didSet {
            value?.addObserver(self)
        }
    }
    private var key : String
    
    public static subscript<EditableOwner: AJREditableObject>(
        _enclosingInstance instance: EditableOwner,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EditableOwner, EditableValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<EditableOwner, AJREditableFriend>
    ) -> EditableValue {
        get {
            return instance[keyPath: storageKeyPath].value!
        }
        set {
            let key = instance[keyPath: storageKeyPath].key
            instance.willChangeValue(forKey: key)
            // First, see if our existing value exists and has and editingContext. If it doesn't, then remove it from the object.
            if let oldValue = instance[keyPath: storageKeyPath].value,
               let editingContext = oldValue.editingContext {
                editingContext.forgetObject(oldValue)
            }
            // Now store the new value.
            instance[keyPath: storageKeyPath].value = newValue
            // And finally, if our owner has an editing context, add the new value to that editing context.
            if let editingContext = instance.editingContext {
                editingContext.addObject(newValue)
                instance.synchronizeObservationState(withFriend: newValue)
            }
            instance.didChangeValue(forKey: key)
        }
    }

    @available(*, unavailable, message: "@AJREditableFriend can only be applied to classes.")
    public var wrappedValue : EditableValue {
        get { fatalError("You called @AJREditableFriend's getter, which shouldn't be possible.") }
        set { fatalError("You called @AJREditableFriend's setter, which shouldn't be possible.") }
    }

    public init(wrappedValue: EditableValue, key: String) {
        self.value = wrappedValue
        self.key = key
    }

    public func object(_ object: Any, didEditKey key: String, withChange change: [AnyHashable : Any]) {
        // TODO: Consider this: Do we need this code? It seems like since our friend is in the editing context, we're properly tracking the games.
        AJRLog.debug("change: \(self.key).\(key): \(change)")
    }
    
}

