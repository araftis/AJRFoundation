//
//  PropertyListProvider.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 2/22/19.
//

import Foundation

@objc public protocol AJRPropertyListProvider {
    
    var propertyList : [String:Any] { get }
    
    init(propertyList: [String:Any])
    
}
