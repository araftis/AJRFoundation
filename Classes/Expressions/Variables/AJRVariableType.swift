//
//  AJRVariableType.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/19/22.
//

import Foundation

/**
 Tracks the type of a variable.
 
 For many uses, this is pretty much ignorable. We usually don't really care what "type" a variable is, as our language for parsing is basically type agnostic. However, at some point, we're going to want to present user interface to editing variables, and for that, we'll need types.
 
 Rather than implementing this as a enumeration, which might seem to most natural, we're going to so this as an object. That's for a number of reasons. One, we need to be able to extend types, especially in the interface layers, so that we can support editing. Two, as we go up the framework stack, we'll want to add more types. For example, the user interface layer will want to add support for rectangles, points, sizes, colors, and maybe fonts. Finally, three, and related to the previous, we'll want the types to be extensible via the plug-in mechanism, and for that we need a factory class and instances of objects.
 
 Note that the class does support AJRXMLCoding, but it isn't expected that the types will actually have data to encode/decode. They can, and there's nothing wrong with that, but mostly we'll just want to make sure we're instantiated the correct variable type when reading back from an archive. As such, subclasses should implement `public class ajr_nameForXMLArchiving`, and they should return something along the lines of `<my_type>Type`. For example, and integer type might return `integerType`.
 */
@objcMembers
open class AJRVariableType : NSObject, AJRXMLCoding {
    
    // MARK: - Properties
    
    /// The name of the type. This should be in English
    open var name : String = "Any"
    /// The localized name of the type for the current locale. By default this is `name`.
    open var localizedDisplayName : String {
        return translator[name]
    }
    
    // MARK: - Creation
    
    required public override init() {
        // We don't actually do anything, this is just required by xml unarchiving.
        super.init()
    }
    
    /// Instantiates an instance from it's plug-in manager properties.
    required public init(from properties: [String:Any]) {
        if let name = properties["name"] as? String {
            self.name = name
        }
    }
    
    // MARK: - Factory
    
    /// Indexes by the class. Unfortunately, in Swift, class types aren't hashable, so we have to do this by the classes name.
    internal static var typesByClass = [String:AJRVariableType]();
    /// Indexes by the variable's name.
    internal static var typesByName = [String:AJRVariableType]();
    /// The ordered variable types. Right now, this is just the order in which the variable types are registered, which is the order in which they are defined in the plug-in data file. That could change in the future.
    internal(set) public static var types = [AJRVariableType]()
    
    public class func registerVariableType(_ variableType: AJRVariableType.Type, properties: [String:Any]) -> Void {
        let instance = variableType.init(from: properties)
        
        typesByClass[NSStringFromClass(variableType)] = instance
        typesByName[instance.name] = instance
        types.append(instance)
        
        AJRLog.in(domain: AJRPlugInManagerLoggingDomain, level: .debug, message: "Registered variable type: \(variableType) (\(instance.name))")
    }
    
    @objc(variableTypeForClass:)
    public class func variableType(for class: AJRVariableType.Type) -> AJRVariableType? {
        return typesByClass[NSStringFromClass(`class`)];
    }
    
    @objc(variableTypeForName:)
    public class func variableType(for name: String) -> AJRVariableType? {
        return typesByName[name];
    }
    
    // MARK: - AJRXMLCoding
    
    /// Grabs the singleton instance from the factory and returns it.
    public class func instantiate(with coder: AJRXMLCoder) -> Any {
        return NSObject()
    }
    
    /// This doesn't actually do anything, but must be here for XML decoding.
    public func decode(with coder: AJRXMLCoder) {
    }
    
    /// We don't do anything. Just encoding our class type is sufficient.
    public func encode(with coder: AJRXMLCoder) {
    }
    
}

@objcMembers
open class AJRVariableTypeBool : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeInteger : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeFloatingPoint : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeString : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeArray : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeSet : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeDictionary : AJRVariableType {
}

@objcMembers
open class AJRVariableTypeDate : AJRVariableType {
}
