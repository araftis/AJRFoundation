//
//  AJRFractionFormatter.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 3/19/23.
//

import Foundation

public extension AJRFractionFormatter {

    func string(fromCGFloat number: CGFloat) -> String? {
        return string(from: NSNumber(value: number))
    }

}
