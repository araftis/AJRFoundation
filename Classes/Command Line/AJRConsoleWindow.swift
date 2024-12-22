//
//  AJRConsoleWindow.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/5/24.
//

import Foundation
import Darwin.ncurses

@objcMembers
open class AJRConsoleWindow : NSObject {

    // MARK: - Properties

    public private(set) var window : OpaquePointer!
    public private(set) weak var parent : AJRConsoleWindow?
    public private(set) var children : [AJRConsoleWindow]?

    // MARK: - Creation

    public init?(parent: AJRConsoleWindow? = nil, width: Int32, height: Int32, x: Int32, y: Int32) {
        super.init()
        if let parent {
            self.window = subwin(parent.window, width, height, x, y)
            parent.addChild(self)
            self.parent = parent
        } else {
            self.window = newwin(width, height, x, y)
        }
        if self.window == nil {
            return nil
        }
    }

    public init(window: OpaquePointer!) {
        self.window = window
    }

    deinit {
        if let parent {
            parent.removeChild(self)
        }
    }

    // MARK: - Parent/Child

    open func addChild(_ child: AJRConsoleWindow) {
        if children == nil {
            children = [AJRConsoleWindow]()
        }
        children!.append(child)
    }

    open func removeChild(_ child: AJRConsoleWindow) {
        if children != nil {
            children?.remove(identicalTo: child)
            child.parent = nil
            if children!.count == 0 {
                children = nil
            }
        }
    }

    // MARK: - Sync

    public enum Sync {
        case up
        case down
        case cursor
    }

    open func sync(_ type: Sync) {
        switch type {
        case .up: wsyncup(window)
        case .down: wsyncdown(window)
        case .cursor: wcursyncup(window)
        }
    }

    // MARK: - Clearing

    @discardableResult
    open func erase() -> AJRConsole.Result {
        return AJRWrapResult(werase(window))
    }

    @discardableResult
    open func clear() -> AJRConsole.Result {
        return AJRWrapResult(wclear(window))
    }

    @discardableResult
    open func clearToBottom() -> AJRConsole.Result {
        return AJRWrapResult(wclrtobot(window))
    }

    @discardableResult
    open func clearToEndOfLine() -> AJRConsole.Result {
        return AJRWrapResult(wclrtoeol(window))
    }

    // MARK: - NSCopying

    open override func copy() -> Any {
        let newWindow = dupwin(window)
        return AJRConsoleWindow.init(window: newWindow)
    }

    // MARK: - I/O

    @discardableResult
    open func print(x: Int32? = nil, y: Int32? = nil, _ string: String) -> Int32 {
        if let x, let y {
            return mvwaddstr(window, y, x, string)
        } else {
            return waddstr(window, string)
        }
    }

}
