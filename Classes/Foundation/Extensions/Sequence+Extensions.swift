//
//  Set+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/29/21.
//

import Foundation

public extension Sequence {

    /**
     Enumerates the values in a Sequence.

     - Note This is mostly here for historical reasons. Just using `for <object> in <Sequence>` is probably you're better approach.

     - parameter block The block to call for each element of the Sequence.
     */
    func enumerate(_ block: (_ object: Element) -> Void) -> Void {
        for object in self {
            block(object)
        }
    }

    /**
     Returns any object padding `test`.

     - returns Any object in the Sequence that matches `test`. If two objects would pass test, the return value is undefined, and could be either object.
     */
    func any(passing test: (_ object: Element) -> Bool) -> Element? {
        for object in self {
            if test(object) {
                return object
            }
        }
        return nil
    }

}

