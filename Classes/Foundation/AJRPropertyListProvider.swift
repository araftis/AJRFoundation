
import Foundation

@objc public protocol AJRPropertyListProvider {
    
    var propertyList : [String:Any] { get }
    
    init(propertyList: [String:Any])
    
}
