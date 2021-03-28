/*
Data+Extensions.swift
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

public extension Data {

    /**
     Generates a test Data object where the values are (1 ... `length`) % 256, or values provided by your block.

     Basically, this makes it easy to visually evaluate the results of a test.

     - parameter length: The length of the data you want.
     - parameter block: If present, the block will be called with an array of UInt8, which you can populate with whatever data you'd like.

     - returns: The generated data object.
     */
    init(testDataOfLength length: Int, using block:((_ data: inout [UInt8]) -> Void)? = nil) {
        var data = [UInt8](repeating: 0, count: length)
        if let block = block {
            block(&data)
        } else {
            for index in 0 ..< length {
                data[index] = UInt8(index % 256)
            }
        }
        self.init(bytes:data, count: length)
    }

    /**
     Poor man's data dump, but somewhat useful for testing.
     */
    var dump : String {
        var string = "(\(self.count))"
        if self.count <= 16 {
            string += " "
        }
        let digits = Int(ceil(log(Double(self.count)) / log(16)))
        for index in self.startIndex ..< self.endIndex {
            let hex = String(self[index], radix: 16)
            if index % 16 == 0 && self.count > 16 {
                if index + startIndex >= 16 {
                    for subindex in index - 16 ..< index {
                        if subindex < self.count + self.startIndex {
                            var value = self[subindex]
                            if value < 32 || (value > 0x7E && value < 0xA0) {
                                value = 0x2E
                            }
                            string.append(Character(Unicode.Scalar(value)))
                        }
                    }
                }
                string += "\n\(String(format: "%0*x", digits, index)): "
            }
            string += (self[index] < 0x10 ? "0" : "") + hex + " "
        }

        let extra =  16 - (self.count - ((self.count / 16) * 16))
        for _ in 0 ..< extra % 16 {
            string.append("   ")
        }
        var startIndex = self.count - (16 - extra)
        if startIndex == self.count && self.count > 16 {
            startIndex -= 16
        }
        for index in startIndex ..< self.count {
            var value = self[self.startIndex + index]
            if value < 32 || (value > 0x7E && value < 0xA0) {
                value = UInt8(46)
            }
            string.append(Character(Unicode.Scalar(value)))
        }

        return string
    }

    @inlinable
    internal static func hexNibbleToInt(_ nibble: UInt8) -> UInt8? {
        if nibble >= 65 && nibble <= 70 {
            return nibble - 55
        }
        if nibble >= 97 && nibble <= 102 {
            return nibble - 87
        }
        if nibble >= 48 && nibble <= 57 {
            return nibble - 48
        }
        return nil
    }

    init?(hexString hex: String) {
        if let ascii = hex.data(using: .ascii) {
            let length = ascii.count
            if length % 2 != 0 {
                // We have to have two digits per
                return nil
            }
            var buffer = [UInt8](repeating: 0, count: length / 2)

            for index in stride(from: 0, to: length, by: 2) {
                if let hiNibble = Data.hexNibbleToInt(ascii[index]),
                   let loNibble = Data.hexNibbleToInt(ascii[index + 1]) {
                    buffer[index / 2] = hiNibble * 16 + loNibble
                } else {
                    return nil
                }
            }
            self.init(buffer)
        } else {
            return nil
        }
    }

    static internal func nibble<T:BinaryInteger>(_ nibble: T) -> T? {
        if nibble < 10 {
            return nibble + 48
        }
        if nibble < 16 {
            return nibble + 55
        }
        return nil
    }

    /**
     A string representing the Data as hex numbers.
     */
    var hexString : String {
        var raw = Data(repeating: 0, count: count * 2)

        for (index, byte) in self.enumerated() {
            raw[index * 2 + 0] = Data.nibble((byte & 0xF0) >> 4)!
            raw[index * 2 + 1] = Data.nibble((byte & 0x0F) >> 0)!
        }

        return String(data: raw, encoding: .ascii)!
    }

    /**
     Generates cryptographically secure random data using Apple's security framework.

     - parameter length: How many bytes you want generated.

     - returns: The random data.
     */
    init?(randomDataOfLength length: Int) {
        var bytes = [UInt8](repeating: 0, count: length)

        if SecRandomCopyBytes(kSecRandomDefault, length, &bytes) != 0 {
            return nil
        }

        self.init(bytes)
    }

    mutating func size(toBits count: Int) -> Void {
        let padCount = count % 8
        let byteCount = count / 8 + (padCount == 0 ? 0 : 1)

        self.count = byteCount

        if padCount != 0 {
            var padMask = UInt8(0)

            for _ in 0 ..< padCount {
                padMask <<= 1
                padMask &= 0x1
            }
            self[byteCount - 1] &= padMask
        }
    }

}

