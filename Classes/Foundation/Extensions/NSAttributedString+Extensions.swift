/*
 NSAttributedString+Extensions.swift
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

public extension NSAttributedString {

    var fullNSRange : NSRange {
        return self.string.fullNSRange
    }

    subscript(range: NSRange) -> NSAttributedString {
        return self.attributedSubstring(from: range)
    }

    func enumerateAttribute(_ name: NSAttributedString.Key, options: NSAttributedString.EnumerationOptions, using block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttribute(name, in: fullNSRange, options: options, using: block)
    }

    func enumerateAttribute(_ name: NSAttributedString.Key, using block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttribute(name, in: fullNSRange, options: [], using: block)
    }

    func enumerateAttributes(options: NSAttributedString.EnumerationOptions, using block: ([NSAttributedString.Key : Any], NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttributes(in: fullNSRange, options: options, using: block)
    }

    func enumerateAttributes(using block: ([NSAttributedString.Key : Any], NSRange, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateAttributes(in: fullNSRange, options: [], using: block)
    }

    func attributes(at index: Int, longestEffectiveRange: NSRangePointer? = nil) -> [NSAttributedString.Key : Any] {
        return attributes(at: index, longestEffectiveRange: longestEffectiveRange, in: fullNSRange)
    }

    func attribute(_ name: NSAttributedString.Key, at index: Int, longestEffectiveRange: NSRangePointer? = nil) -> Any? {
        return attribute(name, at: index, longestEffectiveRange: longestEffectiveRange, in: fullNSRange)
    }

}

public extension NSAttributedString {

    struct TypedKey<T> {
        public var key: NSAttributedString.Key

        public init(key: NSAttributedString.Key) {
            self.key = key
        }
    }

}

public extension NSAttributedString {

    func attribute<T>(typed attrName: NSAttributedString.TypedKey<T>, at location: Int, effectiveRange range: NSRangePointer? = nil) -> Any? {
        return attribute(attrName.key, at: location, effectiveRange: range)

    }

    func attribute<T>(typed name: NSAttributedString.TypedKey<T>, at index: Int, longestEffectiveRange: NSRangePointer? = nil) -> T? {
        return attribute(name.key, at: index, longestEffectiveRange: longestEffectiveRange, in: fullNSRange) as? T
    }

}


