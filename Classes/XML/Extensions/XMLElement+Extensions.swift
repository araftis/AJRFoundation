
import Foundation

// NOTE: This uses fully qualified names, because if we decide to support iOS, then I have an implementation of these classes that use libxml2 under the hood, but that means that the code below would wind up extending our local implementations, rather than the Foundation implementations.

public extension Foundation.XMLElement {
    
    func replaceAttribute(_ attribute: Foundation.XMLNode, with newAttribute: Foundation.XMLNode) {
        if let attributes = attributes {
            var newAttributes = [Foundation.XMLNode]()
            for oldAttribute in attributes {
                removeAttribute(forName: attribute.name!)
                if oldAttribute == attribute {
                    newAttributes.append(newAttribute)
                } else {
                    newAttributes.append(oldAttribute)
                }
            }
            self.attributes = newAttributes
        }
    }
    
}
