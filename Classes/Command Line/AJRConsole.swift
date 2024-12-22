//
//  AJRConsole.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/5/24.
//

import Foundation
import Darwin
import Darwin.ncurses

internal func AJRWrapResult(_ result: Int32) -> AJRConsole.Result {
    if result == ERR {
        return .error
    }
    return .ok
}

/**
 Provides a nice interface for interacting with a virtual console, such as VT100.
 */
@objcMembers
open class AJRConsole : NSObject {

    // MARK: - Shared Enums

    public enum Result {
        case error
        case ok
    }

    // MARK: - Properties

    open var termType : String!
    open var window : AJRConsoleWindow!
    open var width : Int32
    open var height : Int32

    // MARK: - Creation

    private override init() {
        // Make sure people don't call this.
        width = 0
        height = 0
    }

    public init(termType: String? = nil) throws {
        self.termType = termType ?? ProcessInfo.processInfo.environment["TERM"]
        if self.termType == nil {
            throw NSError(domain: NSPOSIXErrorDomain, message: "No terminal specified in the environment. Please set with \"setenv TERM <term_type>\".")
        }

        let window = initscr()
        self.window = AJRConsoleWindow(window: window)
        cbreak()
        noecho()

        width = COLS
        height = LINES
    }

    deinit {
        endwin()
    }

    // MARK: - I/O

    /**
     Calls through to `window.print()`.
     */
    @discardableResult
    open func print(x: Int32? = nil, y: Int32? = nil, _ string: String) -> Int32 {
        return window.print(x: x, y: y, string)
    }

}
