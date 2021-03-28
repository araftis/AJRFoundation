/*
Collection+Extensions.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

public extension Collection {
    
    /**
     Joins the values of a collection into a string.
     
     Joins the components of the collection using `separator` between the objects. If `twoValueSeparator` and `finalSeparator` are supplied this are used between the values when there's only two, or between the last two values. For example, if you call:
     
     ````
     [1].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1"
     ````
     
     If you call:

     ````
     [1, 2].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1 and 2"
     ````
     
     And if you call:
     
     ````
     [1, 2, 3].componentsJoinedByString(separator:", ", twoValueSeparator: " and ", finalSeparator: ", and ")
     ````
     
     you'd get:
     
     ````
     "1, 2, and 3"
     ````
     
     Either one or both of `twoValueSeparator` and `finalSeparator` may be omitted parameters, in which case their values are `nil`.
     
     - parameter separator: The primary string to use between values.
     - parameter twoValueSeparator: The string to use between values when there are exactly two values in the collection. May be nil, in which case `separator` is used.
     - parameter finalSeparator: The tring to use between the final two values of the collection when the collection has three or more values. If `twoValueSeparator` is nil, but `finalSeparator` is not, then the `finalSeparator` will be used between the values in a two value collection.
     
     - returns: The constructed string. See above for examples.
     */
    func componentsJoinedByString(separator:String, twoValueSeparator:String? = nil, finalSeparator:String? = nil) -> String {
        var string = ""
        
        for (index, object) in self.enumerated() {
            if string.isEmpty {
                string += String(describing:object)
            } else {
                if count == 2, let twoValueSeparator = twoValueSeparator {
                    string += twoValueSeparator
                } else if index == count - 1, let finalSeparator = finalSeparator {
                    string += finalSeparator
                } else {
                    string += separator
                }
                string += String(describing:object)
            }
        }
        
        return string
    }
    
    var jsonString : String? {
        var data : Data? = nil
        try? NSObject.catchException {
            data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted, .sortedKeys])
        }
        if let data = data, let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }
    
}
