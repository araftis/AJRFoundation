/*
 AJRVariableType.swift
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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
    open var availableInUI : Bool = false
    
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
        self.availableInUI = properties["availableInUI", false]
    }

    open func createDefaultValue() -> Any? {
        return nil
    }
    
    // MARK: - Factory
    
    /// Indexes by the class. Unfortunately, in Swift, class types aren't hashable, so we have to do this by the classes name.
    internal static var typesByClass = [String:AJRVariableType]();
    /// Indexes by the variable's name.
    internal static var typesByName = [String:AJRVariableType]();
    /// The ordered variable types. Right now, this is just the order in which the variable types are registered, which is the order in which they are defined in the plug-in data file. That could change in the future.
    internal static var _types = [AJRVariableType]()
    public static var types : [AJRVariableType] {
        return _types.sorted { lhs, rhs in
            return lhs.localizedDisplayName < rhs.localizedDisplayName
        }
    }
    
    public class func registerVariableType(_ variableType: AJRVariableType.Type, properties: [String:Any]) -> Void {
        let instance = variableType.init(from: properties)
        
        typesByClass[NSStringFromClass(variableType)] = instance
        typesByName[instance.name.lowercased()] = instance
        _types.append(instance)
        
        AJRLog.in(domain: .plugInManager, level: .debug, message: "Registered variable type: \(variableType) (\(instance.name))")
    }
    
    @objc(variableTypeForClass:)
    public class func variableType(for class: AJRVariableType.Type) -> AJRVariableType? {
        return typesByClass[NSStringFromClass(`class`)];
    }
    
    @objc(variableTypeForName:)
    public class func variableType(for name: String) -> AJRVariableType? {
        return typesByName[name.lowercased()];
    }

    // MARK: - Conversion

    /**
     Converts the `string` to a value of the receiver type.

     This is used for things like property list serialization where the type may be stored as a string. This allows the type to be converted back into an appropriate system type.

     - parameter string: The string containing a representation of the value.

     - returns The value, or possibly `nil`.

     - throws A conversion error if `string` cannot be made into a representation of the type.
     */
    open func value(from string: String) throws -> Any? {
        throw ValueConversionError.conversionNotImplemented("\(type(of:self)) needs to implement \(#function)")
    }

    /**
     Converts the type back into a string.

     This is the inverse operation for `color(from:)`. As such, the returned value should be able to be converted back into the correct value by calling `color(from:)`.

     - parameter value: The value to convert to string. The vaue is non-null, because `null` values will be handled externally.

     - returns A string representation of value.
     */
    open func string(from value: Any) throws -> Any? {
        throw ValueConversionError.conversionNotImplemented("\(type(of:self)) needs to implement \(#function)")
    }
    
    // MARK: - Operator Support
    
    open func possiblyPerform(operator: AJROperator, left: Any?, right: Any?, consumed: inout Bool) throws -> Any? {
        consumed = false
        return nil
    }
    
    open func possiblyPerform(operator: AJROperator, value: Any?, consumed: inout Bool) throws -> Any? {
        consumed = false
        return nil
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

    // MARK: - NSObject

    open override var description: String {
        return name
    }
    
}
