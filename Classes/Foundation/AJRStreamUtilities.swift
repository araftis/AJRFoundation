//
//  AJRStreamUtilities.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 3/16/23.
//

import Foundation

public extension AJRByteReader {
    
    /**
     Reads a line from the stream returning the line or `nil` if end of file has been reached. Throws an error if any errors occur.
     
     Note: This method is implemented specially, becase the Obj-C method has to "return" the error as a parameter, but the default pattern means that the method has to return `nil` only when an error is returned, and for us, we may return `nil` without an error.
     
     - returns The read line, or `nil` if the EOF is reached.
     */
    func readLine() throws -> String? {
        var error : NSError? = nil
        let string = AJRReadLine(self, &error)
        if let error {
            throw error
        }
        return string
    }
    
}
