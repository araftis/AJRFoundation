/*
 String+Extensions.swift
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

public func < (left: ComparisonResult, right: ComparisonResult) -> Bool {
    return left.rawValue < right.rawValue
}

public func > (left: ComparisonResult, right: ComparisonResult) -> Bool {
    return left.rawValue > right.rawValue
}

public func <= (left: ComparisonResult, right: ComparisonResult) -> Bool {
    return left.rawValue <= right.rawValue
}

public func >= (left: ComparisonResult, right: ComparisonResult) -> Bool {
    return left.rawValue >= right.rawValue
}

public extension StringProtocol {

    /// Returns the range of the entire string as an NSRange. This is sometimes useful when working with API's that generally expect to work with NSString, of which there are still a few.
    var fullNSRange : NSRange {
        return NSRange(location: 0, length: self.utf16.count)
    }

    /// Returns the full range of the string.
    var fullRange : Range<String.Index> {
        return self.startIndex ..< self.endIndex
    }

    func range(from range: NSRange) -> Range<String.Index> {
        let firstIndex = startIndex
        let startIndex = index(firstIndex, offsetBy: range.location)
        let endIndex = index(startIndex, offsetBy: range.length)
        return startIndex ..< endIndex
    }

    /// Checks if the receiver has the same prefix as `prefix` ignoring case.
    ///
    /// - parameter prefix The prefix to compare against.
    ///
    /// - returns `true` if the receiver has the prefix `prefix` regardless of case.
    func hasCaseInsensitivePrefix<T: StringProtocol>(_ prefix: T) -> Bool {
        if self.count >= prefix.count {
            let substring = String(self[startIndex..<self.index(startIndex, offsetBy: prefix.count)])
            return substring.caseInsensitiveCompare(prefix) == .orderedSame
        }
        return false
    }
    
    internal var offsetOverLeadingArticle : Self.Index {
        // This seems a bit cumbersome, and it is, but it's signifigantly more efficient than other methods I tried, like 5x faster than actually using the hasCaseInsensitivePrefix method above. True, it's using the UTF-8 view above, but for English, which is what I'm mostly worried about, this should be accurate.
        let utf8 = self.utf8
        
        var possibleThe = false
        var possibleAn = false
        var possibleA = false
        
        for (index, character) in utf8.enumerated() {
            if index == 0 {
                if character == 116 || character == 84 /* t */ {
                    possibleThe = true
                } else if character == 97 || character == 65 /* a */ {
                    possibleA = true
                    possibleAn = true
                }
            } else if index == 1 {
                if possibleThe && !(character == 104 || character == 72) /* h */ {
                    return startIndex
                } else if possibleA && character == 32 /* ' ' */ {
                    return self.index(startIndex, offsetBy: 2)
                } else if possibleAn && !(character == 110 || character == 78) /* n */ {
                    return startIndex
                }
            } else if index == 2 {
                if possibleThe && !(character == 101 || character == 69) /* e */ {
                    return startIndex
                } else if possibleAn && character == 32 /* ' ' */ {
                    return self.index(startIndex, offsetBy: 3)
                }
            } else if index == 3 {
                if possibleThe && character == 32 /* ' ' */ {
                    return self.index(startIndex, offsetBy: 4)
                } else {
                    return startIndex
                }
            }
        }
        return startIndex
    }
    
    subscript(_ range: NSRange) -> SubSequence {
        return self[self.index(self.startIndex, offsetBy: range.location) ... self.index(self.startIndex, offsetBy: range.location + range.length - 1)]
    }

    var firstLetterCapitalized : String {
        if count <= 1 {
            return self.capitalized
        }
        let initial = self.prefix(1).capitalized
        let remainder = self.suffix(from: index(startIndex, offsetBy: 1))
        let string = initial + remainder
        return string
    }
    
}

public extension String {
    
    func hasCaseInsensitivePrefix(_ prefix: String) -> Bool {
        // Oddly, this is pretty horrible inefficient.
        if count < prefix.count {
            return false
        }
        return compare(prefix, options: [.caseInsensitive], range: startIndex ..< index(startIndex, offsetBy: prefix.count), locale: nil) == .orderedSame
    }
    
    func localizedStandardCompareIgnoringLeadingArticle<T>(_ string: T) -> ComparisonResult where T : StringProtocol {
        let left = self[offsetOverLeadingArticle ..< endIndex]
        let right = string[string.offsetOverLeadingArticle ..< string.endIndex]
        return left.localizedStandardCompare(right)
    }
    
    var escapingHTML : String {
        return (self as NSString).escapingHTML()
    }
    
    subscript(_ range: NSRange) -> SubSequence {
        return self[self.index(self.startIndex, offsetBy: range.location) ... self.index(self.startIndex, offsetBy: range.location + range.length - 1)]
    }
    
    func byWrapping(to width: Int, firstLinePrefix: String? = nil, prefix: String, lineSeparator: String = "\n", splitURLs: Bool = true) -> String {
        return (self as NSString).byWrapping(to: width, firstLinePrefix: firstLinePrefix, prefix: prefix, lineSeparator: lineSeparator, splitURLs: splitURLs)
    }

    internal static let spaces = "                                                                                                                                                                                                                                                                                                            "

    init(padding: Int) {
        assert(padding < 300, "Padding must be less than \(String.spaces.count).")
        self.init(String.spaces.prefix(padding))
    }

    init(indent: Int, width: Int = 4) {
        // This let's us optimize the creation, if the indent is less than 300.
        let fullWidth = indent * width
        if fullWidth < String.spaces.count {
            self.init(String.spaces.prefix(fullWidth))
        } else if width < String.spaces.count {
            let substring = String.spaces.prefix(width)
            var tabbed : String = ""
            for _ in 0 ..< indent {
                tabbed += substring
            }
            self.init(tabbed)
        } else {
            preconditionFailure("The tab width must be less than \(String.spaces.count)")
        }
    }

}

