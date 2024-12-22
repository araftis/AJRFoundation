//
//  FileManager+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 6/2/23.
//

import Foundation

public extension FileManager {

    /**
     This basically just calls through to the Obj-C implementation, but we go through this extra step so that the provided block can throw an error.
     */
    func enumerateFiles(matchingPattern pattern: String, using block: @escaping (_ filename: String, _ stop: inout Bool) throws -> Void) throws -> Void {
        var localError : Error? = nil
        try _enumerateFiles(matchingPattern: pattern) { filename, stop in
            do {
                var localStop : Bool = false
                try block(filename, &localStop)
                stop.pointee = ObjCBool(localStop)
            } catch {
                localError = error
                stop.pointee = true
            }
        }
        if let localError {
            throw localError
        }
    }

}
