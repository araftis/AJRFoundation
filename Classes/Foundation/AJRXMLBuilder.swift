//
//  AJRXMLBuilder.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/16/14.
//
//

import Foundation

public typealias AJRXMLBuilderElementBlock = (_ element: XMLElement) -> Void
public typealias AJRXMLBuilderInitialElementBlock = (_ builder: AJRXMLBuilder, _ element: XMLElement) -> Void

@objcMembers
public class AJRXMLBuilder : NSObject {

    // MARK: - Properties
    
    internal var currentElement: XMLElement?

    // MARK: - Creation
    
    public class func element(name: String, scope: AJRXMLBuilderInitialElementBlock) -> XMLElement {
        let pusher = AJRXMLBuilder()
        return pusher.push(name: name) { (element) in
            scope(pusher, element)
        }
    }

    public func push(name: String, scope: AJRXMLBuilderElementBlock) -> XMLElement {
        let returnElement = XMLElement(name: name)
        currentElement?.addChild(returnElement)
        scope(returnElement)
        
        return returnElement
    }

}

@objc
public extension XMLElement {
    
    class func element(name: String, scope: AJRXMLBuilderInitialElementBlock) -> XMLElement {
        return AJRXMLBuilder.element(name: name, scope: scope)
    }

}
