/*
UserDefaults+Extensions.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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
 This protocol should be adopted onto types that wish to be directly gotten from or set into User Defaults. Internally, we've extended the common types used by User Defaults to adopt this protocol: String, Int, Float, Double, Data, URL, Dictionary, Array, and Set. However, if you'd like to use your own types, you can adopt this protocol and implement its two methods. You can then create AJRUserDefaultsKey objects with your type. For example, say you have a simple enumeration:
 
 ````
    public enum State : Int {
        case off = 0
        case on = 1
        case mixed = 2
    }
 ````

 And you want to be able to create a user defaults key:
 
 ````
    static let myKey = AJRUserDefaultsKey<State>(named:"state", defaultValue:false)
 ````

 To do this, you'll modify your struct by making it conform to AJRUserDefaultsKey, which will look like this:
 
 ````
    public enum State : Int {
        case off = 0
        case on = 1
        case mixed = 2

        public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Any? {
            if let string = userDefaults.string(forKey:key) {
                if let integer = Int(string) {
                    return State(rawValue:integer)
                }
            }
            return nil
        }

        public static func setUserDefault(_ value:Any?, forKey key:String, into userDefaults:UserDefaults) {
            userDefaults.set((value as! State).rawValue, forKey:key)
        }
    }
 ````

 In the above example, you'll see that we convert our enum value into a Int and then store that Int into defaults. We can choose any external representation we'd like. For example, this code could have as easily stored a string, but then we'd need to have code to convert my enum to and from a string. One important thing to note in the `userDefault(forKey:from:)` method is that we do not call `userDefaults.integer(forKey:)` directly, because this method doesn't return an option, but rather 0 if the default is not present. To be a good swift citizen, we want to return nil if the key is not set rather than 0. That means we need to fetch the value as a string, which does return nil, and if the value isn't nil, then we convert it to an Int and then into our enum value. As an added note, we also make sure we successfully converted string to an Int, because the user can manipulate the defaults database externally, and therefore the user could store an inappropriate value. In our code, if there is an inappropriate value, we choose to return nil.
 
 */
public protocol AJRUserDefaultProvider {
    
    associatedtype ObjectType = Self
    
    /**
     Reads a default value from the defaults database and returns is as an approprate type, generally the type of the receiver. If the value isn't not present, or the value cannot be "parsed", this method should return nil.
     
     - parameter key: The key to query.
     - parameter from: The UserDefaults to read from.
     
     - returns: The object found or nil if the object doesn't exist.
     */
    static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> ObjectType?

    /**
     Writes the value into the defaults database. The type of value will be match the receiver, so if you need stronger typing, you can cast value into the receiver's type.
     
     - parameter value: The value to set.
     - parameter key: The key for the value.
     */
    static func setUserDefault(_ value:ObjectType?, forKey key:String, into userDefaults:UserDefaults) -> Void
    
}

extension String : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> String? {
        return userDefaults.string(forKey:key)
    }
    
    public static func setUserDefault(_ value:String?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

extension Int : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Int? {
        let string = userDefaults.string(forKey:key)
        return string == nil ? nil : Int(string!)
    }
    
    public static func setUserDefault(_ value:Int?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

extension Float : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Float? {
        let string = userDefaults.string(forKey:key)
        return string == nil ? nil : Float(string!)
    }
    
    public static func setUserDefault(_ value:Float?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

extension Double : AJRUserDefaultProvider {

    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Double? {
        let string = userDefaults.string(forKey:key)
        return string == nil ? nil : Double(string!)
    }

    public static func setUserDefault(_ value:Double?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }

}

extension CGFloat : AJRUserDefaultProvider {

    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> CGFloat? {
        let string = userDefaults.string(forKey:key)
        if let string = string, let double = Double(string) {
            return CGFloat(double)
        }
        return nil
    }

    public static func setUserDefault(_ value:CGFloat?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }

}

extension Bool : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Bool? {
        let string = userDefaults.string(forKey:key)
        return string == nil ? nil : Int(string!) != 0
    }
    
    public static func setUserDefault(_ value:Bool?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

extension URL : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> URL? {
        var url : URL? = nil
        if let data = userDefaults.data(forKey: key) {
            var isStale = false
            url = try? URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
        } else {
            url = userDefaults.url(forKey:key)
        }
        return url
    }
    
    public static func setUserDefault(_ value:URL?, forKey key:String, into userDefaults:UserDefaults) {
        if let data = ((try? value?.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)) as Data??) {
            userDefaults.set(data, forKey: key)
        } else {
            userDefaults.set(value, forKey: key)
        }
    }
    
}

extension Dictionary {
    func map<T, V>(transform: (Key, Value) -> (T, V)) -> Dictionary<T, V> {
        var d = Dictionary<T, V>()
        for (key, value) in self {
            let (newKey, newValue) = transform(key, value)
            d[newKey] = newValue
        }
        return d
    }
}

extension Dictionary : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Dictionary? {
        guard let values = userDefaults.dictionary(forKey:key) else {
            return nil
        }
        return values.map { ($0 as! Key, $1 as! Value) }
    }
    
    public static func setUserDefault(_ value:Dictionary?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

// TODO: Move these somewhere better

public protocol AJRCustomPropertyListConvertible {
    
    static func instance(fromPropertyListValue propertyListValue: Any) -> Self?
    var propertyListValue : Any { get }
    
}

extension URL : AJRCustomPropertyListConvertible {

    public static func instance(fromPropertyListValue propertyListValue: Any) -> URL? {
        var result : URL? = nil
        if let value = propertyListValue as? Data {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: value, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale) {
                result = url
            }
        } else if let value = propertyListValue as? String {
            result = URL(string: value)
        }
        return result
    }
    
    public var propertyListValue: Any {
        if isFileURL, let data = (try? self.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)) as Data? {
            return data
        }
        return absoluteString
    }
    
}

extension Array : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Array<Element>? {
        guard let values = userDefaults.array(forKey:key) else {
            return nil
        }
        if Element.self is AJRCustomPropertyListConvertible.Type {
            return values.compactMap { (Element.self as! AJRCustomPropertyListConvertible.Type).instance(fromPropertyListValue: $0) as? Element }
        }
        return values.map { $0 as! Element }
    }
    
    public static func setUserDefault(_ value:Array?, forKey key:String, into userDefaults:UserDefaults) {
        if let value = value {
            if type(of: value).Element.self is AJRCustomPropertyListConvertible.Type {
                let newValue = value.map { return ($0 as! AJRCustomPropertyListConvertible).propertyListValue }
                userDefaults.set(newValue, forKey: key)
            } else {
                userDefaults.set(value, forKey: key)
            }
        } else {
            userDefaults.set(nil, forKey:key)
        }
    }
    
}

extension Set : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Set? {
        guard let values = userDefaults.array(forKey:key) else {
            return nil
        }
        if Element.self is AJRCustomPropertyListConvertible.Type {
            return Set(values.compactMap { (Element.self as! AJRCustomPropertyListConvertible.Type).instance(fromPropertyListValue: $0) as? Element })
        }
        return Set(values.map { $0 as! Element })
    }
    
    public static func setUserDefault(_ value:Set?, forKey key:String, into userDefaults:UserDefaults) {
        if let value = value {
            if type(of: value).Element.self is AJRCustomPropertyListConvertible.Type {
                let newValue = value.map { return ($0 as! AJRCustomPropertyListConvertible).propertyListValue }
                userDefaults.set(Array(newValue), forKey: key)
            } else {
                userDefaults.set(Array(value), forKey: key)
            }
        } else {
            userDefaults.set(nil, forKey:key)
        }
    }
    
}

extension Data : AJRUserDefaultProvider {
    
    public static func userDefault(forKey key:String, from userDefaults:UserDefaults) -> Data? {
        return userDefaults.data(forKey:key)
    }
    
    public static func setUserDefault(_ value:Data?, forKey key:String, into userDefaults:UserDefaults) {
        userDefaults.set(value, forKey:key)
    }
    
}

private func autocast<T>(_ some:Any?) -> T? {
    return some as? T
}

/**
 `AJRUserDefaultsKey` represent an entry in the user defaults database that carries both type and a default value.
 
 Create these keys to better access UserDefaults in a type safe manner.
 
 # Usage
 
 To use, you simply declare a new key:

 ````
    public static let myKey = AJRUserDefaultsKey<Int>(named:"myValue", defaultValue:100)
 ````
 
 And you can then access your default in two ways. First, you could call the UserDefaults object itself. For example:
 
 ````
    let myInteger = UserDefaults.standard.get(forKey:myKey)!
 ````

 Note that in this case, it's safe to force unwrap, because we've provided a "defaultValue" when creating the key. If we didn't provide a default value, then nil could be returned.
 
 If you'd like a shorter way to get your value, as a convenience, if you're only use `UserDefaults.standard`, then you can also ask the key for it's associated, underlying value by call:
 
 ````
    let myInteger = myKey.value! // Equivalent to UserDefaults.standard.get(forKey:myKey)!
 ````

 And you can also assign to value, so you could also call:
 
 ````
    myKey.value = 200 // Equivalent to UserDefaults.standard.set(200, forKey:myKey)
 ````

 Which would change the user default to 200.
 
 If you no longer want a user default stored for you value, you can clear the value by calling:
 
 ````
    // These four methods are equivalent
    UserDefaults.standard.remove(forKey:myKey)
    UserDefaults.standard.set(nil, forKey:myKey)
    myKey.value = nil
    myKey.reset()
 ````

 The final method is probably the clearest, because it indicates that the value will be reset back to it's default value, which is what happens when you remove a value. If you'd rather get nil back when a default isn't set, then do not provide a default value.
 
 # Default Values
 
 Note that when we created myKey, we opted to provide a default value, but would could have also set it to nil, or left it blank. For example:
 
 ````
    public static let myKey = AJRUserDefaultsKey<Int>(named:"myValue")
 ````

 When a key has no default value, accessing the key's value will return nil if it's not set. Likewise, the defaultValue is actually an autoclosure, you so you use an expression for the default value. For example, say we want a default that is equal to the current year. To achieve this, we could declare:
 
 ````
    public static let year = AJRUserDefaultsKey<Int>(named:"year", defaultValue:Calendar.current.dateComponents([.year], from:Date()).year!)
 ````

 Now, when the value is nil, the expression will be evaluated and the result returned.
 
 # Scoping
 
 You might not want to consider not cluttering up your code with a bunch of unscoped user default keys. To avoid, this you can scope your keys. For example, if you could create a struct to encapsulate your keys into a name space. For example:
 
 ````
    internal struct MyDefaults {
        public static let key1 = AJRUserDefaultsKey<Int>(named:"default1", defaultValue:1)
    }
 ````

 Then, in other places within your module, you can extend this struct. For example:
 
 ````
    internal extension MyDefaults {
        public static let key2 = AJRUserDefaultsKey<Float>(named:"default2", defaultValue:3.14159)
    }
 ````

 Now, of course, when accessing your key, you'd include the namespace:
 
 ````
    let myValue = MyDefaults.key1.value!
 ````

 On the other hand, if you'd like even finer scoping, you can also include keys in other namespaces. For example, say you want your keys to be isolated by class. In this case, you could write:
 
 ````
    internal class MyClass {
        internal struct Keys {
            public static let key = AJRUserDefaultsKey<Int>(named:"default", defaultValue:1)
        }
    }
 ````

 And of course from within your class you'd access it by calling Keys.key, or from within your framework, you'd call `MyClass.Keys.key`. Obviously, declaring the struct as private would limit visibility to just your class.
 
 # Conclusion
 
 `AJRUserDefaultsKey` is provided to encapsulate type into your use of `UserDefaults`. This saves you from having to constant write a bunch of error handling and type casting code to access your values in the user defaults.
 
 Finally, see AJRUserDefaultProvider for an explanation of how you can make your own types available for use with AJRUserDefaultsKey.
 */
public class AJRUserDefaultsKey<T:AJRUserDefaultProvider> {
    
    /**
     Stores the name of the key. This is the key used to UserDefault's standard methods, and it will be passed through to the AJRUserDefaultProvider.
     */
    public var key : String
    /**
     The defaultValue as a closure. If the value in defaults is currently nil, this closure, if set, is called and the value it produces is returned.
     */
    public var defaultValue : (() -> T?)?
    
    /**
     Creates and returns a new key.
     
     Creates and returns a new key.
     
     - parameter key: The value used to name the user default and is passed to the native UserDefault's method.
     - parameter defaultValue: This is nil by default, but may be any expression that returns type T. Use this to return a default value when defaults current has no value for `key`.
     */
    public init(named key:String, defaultValue:@escaping @autoclosure()->T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    /**
     The workhorse method for getting the typed value from `UserDefaults`.
     
     Returns the value as fetched from the provided UserDefaults, defaults. This method simply delegates through to T, which will be a AJRUserDefaultProvider, by calling T.userDefault(forKey:key, from:defaults). This method will return nil if the value is not set, rather than the default value. The return of the default value is controlled by the extension on UserDefaults itself. This basically means that the caller can determine the difference between an unset default value and an unset value, if needed.
     
     - parameter defaults: The UserDefaults object from which to fetch the default.

     - returns: The typed from from `defaults`.
     */
    public func get(from defaults:UserDefaults) -> T? {
        return T.userDefault(forKey:self.key, from:defaults) as? T
    }
    
    /**
     The workhorse setting for putting typed values into `UserDefaults`.
     
     Sets value in userDefaults. Value may be nil, which means remove the value from user defaults. Removing a value means that in the future, calls to UserDefaults will return nil.
     
     - parameter value: The value to put into `userDefaults`.
     - parameter userDefaults: The `UserDefaults` instance in which to store the value.
     */
    public func set(_ value:T?, into userDefaults:UserDefaults) -> Void {
        T.setUserDefault(autocast(value), forKey:self.key, into:userDefaults)
    }

    /**
     A convenience for the `set` and `get` methods which uses `UserDefaults.standard`.
     
     This is basically a short cut, so that rather than having to call `UserDefaults.standard.get(forKey:MyKeySpace.myKey)`, you could instead just call `MyKeySpace.myKey.value`. The same is true for setting, so you could call `MyKeySpace.myKey.value = value`.
     */
    public var value : T? {
        get {
            return UserDefaults.standard.get(forKey:self)
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey:self)
        }
    }
    
    /**
     Resets the value in the user defaults.
     
     This is basically like a remove, and it does remove the value from the User Defaults, however, once the value is removed, the default value will be returned, which is why this is "reset" vs. "remove".
     */
    public func reset() -> Void {
        UserDefaults.standard.remove(key:self)
    }
    
    /** Checks to see if the key named `name` has already been creating, and if it has, the key is returned. Otherwise, the key is cached and then returned. This is necessary, beacuse Swift doesn't allow classes qualified with types to contain static members, so we have to "cache" the values of the keys to prevent creating multiple copies. */
    public static func key<T>(named name: String, defaultValue: T? = nil) -> AJRUserDefaultsKey<T> {
        var key : AJRUserDefaultsKey<T>?
        
        userDefaultKeyLock.lock()
        key = userDefaultKeys[name] as? AJRUserDefaultsKey<T>
        if key == nil {
            key = AJRUserDefaultsKey<T>(named: name, defaultValue: defaultValue)
            userDefaultKeys[name] = key
        }
        userDefaultKeyLock.unlock()
        
        return key!
    }
    
    // MARK: - Observing
    
    @objcMembers
    internal class AJRUserDefaultObserver : NSObject {
        
        var userDefaultsKey : AJRUserDefaultsKey
        
        init(_ userDefaultsKey: AJRUserDefaultsKey) {
            self.userDefaultsKey = userDefaultsKey
            super.init()
            UserDefaults.standard.addObserver(self, forKeyPath: userDefaultsKey.key, options: [], context: nil)
        }
        
        deinit {
            UserDefaults.standard.removeObserver(self, forKeyPath: userDefaultsKey.key)
        }
        
        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            userDefaultsKey.observersLock.lock()
            defer { userDefaultsKey.observersLock.unlock() }
            do {
                try NSObject.catchException {
                    for entry in self.userDefaultsKey.observers {
                        entry.value()
                    }
                }
            } catch {
                AJRLog.warning("An exception occurred while notify user default observers: \(error)")
            }
        }
        
    }
    
    internal var internalObserver : AJRUserDefaultObserver?
    internal var observersLock = NSLock()
    internal var observers = [Int:() -> Void]()
    internal var observerToken : Int = 0
    
    public func addObserver(callInitially: Bool = false, _ observer: @escaping () -> Void) -> Any {
        observersLock.lock()
        observerToken += 1
        observers[observerToken] = observer
        if internalObserver == nil {
            internalObserver = AJRUserDefaultObserver(self)
        }
        observersLock.unlock()
        
        if callInitially {
            observer()
        }
        
        return observerToken
    }
    
    public func removeObserver(_ token: Any) -> Void {
        if let token = token as? Int {
            observersLock.lock()
            observers.removeValue(forKey: token)
            observersLock.unlock()
        }
    }
    
    public class func addObserver(callInitially: Bool = false, to key: AJRUserDefaultsKey<T>, _ observer: @escaping () -> Void) -> Any {
        return (key: key, token: key.addObserver(callInitially: callInitially, observer))
    }
    
    public class func removeObserver(_ tokenIn: Any) -> Void {
        if let token = tokenIn as? (key: AJRUserDefaultsKey<T>, token: Any) {
            token.key.removeObserver(token.token)
        }
    }
    
}

internal var userDefaultKeyLock = NSLock()
internal var userDefaultKeys = [String:Any]()

public extension UserDefaults {
    
    /**
     Gets and returns a default for the provided key.
     
     The type of the returned value is encapsulated in key. As the value can be in an unset state, the return value is also optional. Note that if the key provides a default value, if the value is unset, the default value will be returned.
     
     - parameter key: The key to use when fetching from defaults.
     
     - returns: The value found or nil.
     */
    func get<T>(forKey key:AJRUserDefaultsKey<T>) -> T? {
        return key.get(from:self) ?? (key.defaultValue == nil ? nil : key.defaultValue!())
    }
    
    /**
     Sets a default value for the given key.
     
     The type of value is encapsulated in key. Value may be nil, which removes the value from the user defaults. If the key has a default value, passing nil here will cause a subsequent call to get(forKey:) to return the default value.
     
     - parameter value: The value to set. May be nil to "remove" the value, although this might represent a reset if the key has a default value.
     - parameter key: The key to set.
     */
    func set<T>(_ value:T?, forKey key:AJRUserDefaultsKey<T>) -> Void {
        key.set(value, into:self)
    }

    /**
     Removes the value from user defaults.
     
     If the key has a default value, subsequent calls to get(forKey:) will return the default value.
     
     - parameter key: The key to remove.
     */
    func remove<T>(key:AJRUserDefaultsKey<T>) -> Void {
        self.removeObject(forKey:key.key)
    }
    
    /**
     Looks up the user default for `key`. The return types is determined by the type as defined on the `AJRUserDefaultKey` instance.
     
     - parameter key: The key to lookup.
     */
    subscript<T>(key:AJRUserDefaultsKey<T>) -> T? {
        get {
            return self.get(forKey:key)
        }
        set(newValue) {
            self.set(newValue, forKey:key)
        }
    }
    
    /**
     Returns the default value as defined on `UserDefaults.standard`, which is the usually domain you'll like want to query for user default values.
     
     - parameter key: The key to lookup.
     */
    static subscript<T>(key:AJRUserDefaultsKey<T>) -> T? {
        get {
            return self.standard.get(forKey:key)
        }
        set(newValue) {
            self.standard.set(newValue, forKey:key)
        }
    }
    
}
