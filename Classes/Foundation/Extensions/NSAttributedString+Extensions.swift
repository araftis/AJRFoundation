//
//  NSAttributedString+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 11/12/22.
//

import Foundation

public extension NSAttributedString {

    subscript(range: NSRange) -> NSAttributedString {
        return self.attributedSubstring(from: range)
    }

}
