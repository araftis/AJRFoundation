/*
 XMLNodeWithChildrenLinux.swift
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#if os(Linux) || os(iOS) || os(tvOS) || os(watchOS)

import Foundation

protocol XMLNodeWithChildren {
    
    func manipulateChildren(_: (inout [XMLNode]?) -> Void) -> Void
    
    var children : [XMLNode]? { get set }
    var childCount : Int { get }

    func child(at index: Int) -> XMLNode?
    func insertChild(_ child: XMLNode, at index:Int)
    func insertChildren(_ children: [XMLNode], at index:Int)
    func removeChild(at index: Int)
    func addChild(_ child: XMLNode)
    func replaceChild(at index: Int, with node: XMLNode)

}

extension XMLNodeWithChildren {
    
    // Beacuse we also have to call this from XMLNode
    internal func set(children newValue: [XMLNode]?) -> Void {
        manipulateChildren { (children) in
            if let currentChildren = children {
                for child in currentChildren {
                    child.detach()
                }
            }
            if newValue != nil {
                // Delay added the children until below, because addChild also calls manipulateChildren
                children = [XMLNode]()
            } else {
                children = nil
            }
        }
        if let newChildren = newValue {
            for child in newChildren {
                addChild(child)
            }
        }
    }
    
    public var chlidren : [XMLNode]? {
        get {
            var result: [XMLNode]? = nil
            manipulateChildren { (children) in
                result = children
            }
            return result
        }
        set(newValue) {
            set(children: newValue)
        }
    }
    
    public var childCount : Int {
        var index: Int = 0
        manipulateChildren { (children) in
            index = children?.count ?? 0
        }
        return index
    }
    
    public func index(ofChild child: XMLNode) -> Int? {
        var index : Int? = nil
        manipulateChildren { (children) in
            index = children?.firstIndex(where: { $0 === child })
        }
        return index
    }
    
    public func child(at index: Int) -> XMLNode? {
        var child : XMLNode? = nil
        
        manipulateChildren { (children) in
            child = children?[index]
        }
        
        return child
    }
    
    public func insertChild(_ child: XMLNode, at index:Int) {
        manipulateChildren { (children) in
            if children == nil {
                children = [XMLNode]()
            }
            children?.insert(child, at: index)
            child.parent = self as? XMLNode
        }
    }
    
    public func insertChildren(_ children: [XMLNode], at index:Int) {
        for (childIndex, child) in children.enumerated() {
            insertChild(child, at: index + childIndex)
        }
    }
    
    public func removeChild(at index: Int) {
        manipulateChildren { (children) in
            if children != nil {
                let child = children![index]
                child.detach()
                children!.remove(at: index)
            }
        }
    }
    
    public func addChild(_ child: XMLNode) -> Void {
        insertChild(child, at: childCount)
    }
    
    public func replaceChild(at index: Int, with node: XMLNode) -> Void {
        manipulateChildren { (children) in
            if children != nil {
                // We could just call remove/insert, but this is faster since we don't have to overly manipulate the size of the underlying Array
                if children == nil {
                    children = [XMLNode]()
                }
                let child = children![index]
                child.detach()
                children![index] = node
                node.parent = self as? XMLNode
            }
        }
    }
    
    public func replaceChild(_ child: XMLNode, with node: XMLNode) -> Void {
        if let index = index(ofChild: child) {
            replaceChild(at: index, with: node)
        }
    }
    
    public func removeChild(_ child: XMLNode) {
        if let index = index(ofChild: child) {
            removeChild(at: index)
        }
    }
    
    @discardableResult public func removeAllChildren() -> [XMLNode]? {
        var childrenForReturn : [XMLNode]? = nil
        
        manipulateChildren { (children) in
            childrenForReturn = children
            
            if let children = children {
                for child in children {
                    child.detach()
                }
            }
            children = nil
        }
        
        return childrenForReturn
    }
    
    public func copyChildren() -> [XMLNode]? {
        var newChildren : [XMLNode]? = nil
        
        manipulateChildren { (children) in
            newChildren = children?.map({ (child) -> XMLNode in
                let newChild = child.copy() as! XMLNode
                newChild.parent = self as? XMLNode
                return newChild
            })
        }
        
        return newChildren
    }
    
    public func replaceAllDescendents(matching match: XMLNode, with newNode: XMLNode? = nil) -> Void {
        if let children = self.children {
            for child in children {
                if match == child {
                    if let newNode = newNode {
                        replaceChild(child, with: newNode.copy() as! XMLNode)
                    } else {
                        removeChild(child)
                    }
                }
                if let child = child as? XMLNodeWithChildren {
                    child.replaceAllDescendents(matching: match, with: newNode)
                }
            }
        }
    }
    
}

#endif
