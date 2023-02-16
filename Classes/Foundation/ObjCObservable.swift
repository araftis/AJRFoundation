//
//  ObjCObservable.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 2/15/23.
//

import Foundation

@propertyWrapper
public struct AJRObjCObservable<T> {
    
    private var key : String
    private var value : T
    
    public static subscript<EditableOwner: AJREditableObject>(
        _enclosingInstance instance: EditableOwner,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EditableOwner, T>,
        storage storageKeyPath: ReferenceWritableKeyPath<EditableOwner, Self>
    ) -> T {
        get {
            return instance[keyPath: storageKeyPath].value
        }
        set {
            let key = instance[keyPath: storageKeyPath].key
            instance.willChangeValue(forKey: key)
            instance[keyPath: storageKeyPath].value = newValue
            instance.didChangeValue(forKey: key)
        }
    }
    
    @available(*, unavailable, message: "@AJRObjCObservable can only be applied to classes.")
    public var wrappedValue : T {
        get { fatalError("You called @AJRObjCObservable's getter, which shouldn't be possible.") }
        set { fatalError("You called @AJRObjCObservable's setter, which shouldn't be possible.") }
    }
    
    public init(wrappedValue: T, key: String) {
        self.value = wrappedValue
        self.key = key
    }
    
}

