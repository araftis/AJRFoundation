//
//  AJRActivity.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/11/23.
//

import Foundation

public extension AJRActivityIdentifier {

    static var uniqueIdentifier : AJRActivityIdentifier {
        return AJRActivityIdentifier(ProcessInfo.processInfo.globallyUniqueString)
    }

}
