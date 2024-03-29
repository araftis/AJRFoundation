/*
 NSOutputStream+Extensions.swift
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

public extension OutputStream {

    /**
     Re-declares this property in a more Swift friendly manner, since Swift doesn't need to worry about the name collision.
     */
    var data : Data? {
        return ajr_data
    }

    /**
     If the receiver is a memory output stream, the data is converting to string using the provided encoding. If the data doesn't exist or cannot be converted to the string encoding this method returns nil.

     This is a Swift friendlier API to a similar Obj-C method.

     - parameter encoding The desired string encoding.

     - returns The string representation of data, or nil.
     */
    func dataAsString(using encoding: String.Encoding) -> String? {
        if let data = data {
            return String(data: data, encoding: encoding)
        }
        return nil
    }
    
    /**
     A convenience for writing indents. This basically allows you to inline writing indents, at least in Swift.
     
     The basic for would be:

     ```
     ouputStream.indent(2).write()
     ```
     
     - parameter indent: The number of indents
     - parameter width: The width of the indent. The default is 3. If 0, then`\t` is used instead.
     
     - returns This returns itself, which allows you to chain.
     */
    func indent(_ indent: Int, width: Int = 4) throws -> OutputStream {
        try writeIndent(indent, width: width)
        return self
    }

}
