/*
 CharacterSet+Extensions.swift
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

public extension CharacterSet {

    static var swiftIdentifierStartCharacterSet : CharacterSet {
        var characterSet = CharacterSet()
        characterSet.insert(charactersFrom:"A", to:"Z")
        characterSet.insert(charactersFrom:"a", to:"z")
        characterSet.insert("_")
        characterSet.insert(0x00A8)
        characterSet.insert(0x00AA)
        characterSet.insert(0x00AD)
        characterSet.insert(0x00AF)
        characterSet.insert(charactersFrom:0x00B2, to:0x00B5)
        characterSet.insert(charactersFrom:0x00B7, to:0x00BA)
        characterSet.insert(charactersFrom:0x00BC, to:0x00BE)
        characterSet.insert(charactersFrom:0x00C0, to:0x00D6)
        characterSet.insert(charactersFrom:0x00D8, to:0x00F6)
        characterSet.insert(charactersFrom:0x00F8, to:0x00FF)
        characterSet.insert(charactersFrom:0x0100, to:0x02FF)
        characterSet.insert(charactersFrom:0x0370, to:0x167F)
        characterSet.insert(charactersFrom:0x1681, to:0x180D)
        characterSet.insert(charactersFrom:0x180F, to:0x1DBF)
        characterSet.insert(charactersFrom:0x1E00, to:0x1FFF)
        characterSet.insert(charactersFrom:0x200B, to:0x200D)
        characterSet.insert(charactersFrom:0x202A, to:0x202E)
        characterSet.insert(charactersFrom:0x203F, to:0x2040)
        characterSet.insert(0x2054)
        characterSet.insert(charactersFrom:0x2060, to:0x206F)
        characterSet.insert(charactersFrom:0x2070, to:0x20CF)
        characterSet.insert(charactersFrom:0x2100, to:0x218F)
        characterSet.insert(charactersFrom:0x2460, to:0x24FF)
        characterSet.insert(charactersFrom:0x2776, to:0x2793)
        characterSet.insert(charactersFrom:0x2C00, to:0x2DFF)
        characterSet.insert(charactersFrom:0x2E80, to:0x2FFF)
        characterSet.insert(charactersFrom:0x3004, to:0x3007)
        characterSet.insert(charactersFrom:0x3021, to:0x302F)
        characterSet.insert(charactersFrom:0x3031, to:0x303F)
        characterSet.insert(charactersFrom:0x3040, to:0xD7FF)
        characterSet.insert(charactersFrom:0xF900, to:0xFD3D)
        characterSet.insert(charactersFrom:0xFD40, to:0xFDCF)
        characterSet.insert(charactersFrom:0xFDF0, to:0xFE1F)
        characterSet.insert(charactersFrom:0xFE30, to:0xFE44)
        characterSet.insert(charactersFrom:0xFE47, to:0xFFFD)
        characterSet.insert(charactersFrom:0x10000, to:0x1FFFD)
        characterSet.insert(charactersFrom:0x20000, to:0x2FFFD)
        characterSet.insert(charactersFrom:0x30000, to:0x3FFFD)
        characterSet.insert(charactersFrom:0x40000, to:0x4FFFD)
        characterSet.insert(charactersFrom:0x50000, to:0x5FFFD)
        characterSet.insert(charactersFrom:0x60000, to:0x6FFFD)
        characterSet.insert(charactersFrom:0x70000, to:0x7FFFD)
        characterSet.insert(charactersFrom:0x80000, to:0x8FFFD)
        characterSet.insert(charactersFrom:0x90000, to:0x9FFFD)
        characterSet.insert(charactersFrom:0xA0000, to:0xAFFFD)
        characterSet.insert(charactersFrom:0xB0000, to:0xBFFFD)
        characterSet.insert(charactersFrom:0xC0000, to:0xCFFFD)
        characterSet.insert(charactersFrom:0xD0000, to:0xDFFFD)
        characterSet.insert(charactersFrom:0xE0000, to:0xEFFFD)
        return characterSet
    }
    
    static var swiftIdentifierCharacterSet : CharacterSet {
        var characterSet = swiftIdentifierStartCharacterSet
        characterSet.insert(charactersFrom:"0", to:"9")
        characterSet.insert(charactersFrom:0x0300, to:0x036F)
        characterSet.insert(charactersFrom:0x1DC0, to:0x1DFF)
        characterSet.insert(charactersFrom:0x20D0, to:0x20FF)
        characterSet.insert(charactersFrom:0xFE20, to:0xFE2F)
        return characterSet
    }
    
    mutating func insert(character: Character) -> Void {
        for scalar in character.unicodeScalars {
            insert(scalar)
        }
    }
    
    mutating func insert(_ character: Int) -> Void {
        insert(Unicode.Scalar(character)!)
    }
    
    mutating func insert(charactersFrom startCharacter: Int, to endCharacter: Int) -> Void {
        insert(charactersIn: Unicode.Scalar(startCharacter)!...Unicode.Scalar(endCharacter)!)
    }
    
    mutating func insert(charactersFrom startCharacter: Unicode.Scalar, to endCharacter: Unicode.Scalar) -> Void {
        insert(charactersIn: startCharacter...endCharacter)
    }
    
    func contains(_ character: Character) -> Bool {
        for scalar in character.unicodeScalars {
            if !contains(scalar) {
                return false
            }
        }
        return true
    }
    
}
