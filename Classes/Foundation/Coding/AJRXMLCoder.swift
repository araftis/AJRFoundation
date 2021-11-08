//
//  AJRXMLCoder.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 11/7/21.
//

import Foundation

public protocol AJRXMLEncodableEnum: CaseIterable, CustomStringConvertible {

    init?(string: String)

}

public extension AJRXMLEncodableEnum {

    init?(string: String) {
        if let found = Self.allCases.first(where: { string == $0.description }) {
            self = found
        } else {
            return nil
        }
    }

}

public extension AJRXMLCoder {

    func encode<T: AJRXMLEncodableEnum>(_ enumeration: T, forKey key: String) {
        encode("\(enumeration)", forKey: key)
    }

    func decodeEnumeration<T: AJRXMLEncodableEnum>(forKey key: String, setter: @escaping (_ value: T?) -> Void) {
        decodeString(forKey: key) { stringValue in
            setter(T.init(string: stringValue))
        }
    }

}
