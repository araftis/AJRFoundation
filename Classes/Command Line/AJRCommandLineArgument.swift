//
//  AJRCommandLineArgument.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 4/29/23.
//

import Cocoa

public let AJRCommandLineArgumentErrorDomain = "AJRCommandLineArgumentErrorDomain"

@objcMembers
open class AJRCommandLineArgument: NSObject {

    /// The name of the argument. For example, `--output`.
    open var name : String? = nil
    /// The short name of the argument. For example, `-o`
    open var shortName : String? = nil
    /// A long string describing the purpose of the argument. Don't worry about wrapping the text, it will be wrapped for you when help is printed. For example: Specifiy a path where the output will be written.
    open var help : String? = nil
    /// A short version of the help. For example: &lt;output\_path&gt;
    open var shortHelp : String? = nil
    /// If `true`, the argument can repeat.
    open var repeatCount : UInt? = 1
    /// If `true`, the argument must be supplied on the command line.
    open var required : Bool = false
    /// The number of expected parameters. This can be `nil`, which means that the number of parameters be be variable, which can include 0. For an argument with no parameters, this may also be 0, rather than `nil`.
    open var numberOfParameters : UInt? = nil
    /// The number of times the argument has been used. If `repeats` is `false`, then this count should never be more than 1.
    open var usedCount : Int = 0
    /// This block is called to apply the argument to the
    open var applyBlock : (_ values: [Any]) throws -> UInt

    /**
     Creates a new argument. Note that you're generally going to want to create an `AJRTypedCommandLineArgument`, otherwise you won't have a way to get the argument's value.

     - Parameter name: The name of the argument. This is represented on the command line by "long" arguments that begin with `--`. For example: `--help`. Arguments may have no name.
     - Parameter shortName: The short name of the argument. Arguments may have no `shortName`. This represents the arguments that begin with a single `-`, for example: `-h`.
     - Parameter help: Long help text for the argument. Don't worry about line breaks. Those will be generated when needed.
     - Parameter shortHelp: The short help for the text. This is used as part of the command summary.
     - Parameter repeatCount: The number of times the parameter can appear. `nil` means the parameter can repeat indefinitely. Zero means that the parameter can never be used, so don't use it.
     - Parameter required: If `true`, if the argument has not been used by the end of processing, then an usage message will be generated.
     - Parameter numberOfParameters: This is generally `nil` or `1`, but it's possible you may have arguments that required two parameters. Basically, `AJRMain` will pass you `numnberOfParameters` arguments to your block. `nil` means that the argument has no parameters.
     - Parameter block: A block that will be called when you parameter is used. In this block you should do things like set the value of your `AJRMain` subclass's properties.
     */
    public init(name: String? = nil,
                shortName: String? = nil,
                help: String? = nil,
                shortHelp: String? = nil,
                repeatCount: UInt? = 1,
                required: Bool = false,
                numberOfParameters: UInt? = nil,
                block: @escaping (_ values: [Any]) throws -> UInt) {
        self.name = name
        self.applyBlock = block

        super.init()

        self.shortName = shortName
        self.help = help
        self.shortHelp = shortHelp
        self.repeatCount = repeatCount
        self.required = required
        self.numberOfParameters = numberOfParameters
    }

    /**
     This method does nothing and is here to be overridden. See `AJRTypedCommandLineArgument` for details.

     - Parameter parameters: The raw command line arguments. The method will be passed `numberOfParameters` strings from the caller. If `numberOfParameters` is `nil`, the caller will receive all remaining arguments on the command line.

     - Returns: The number of parameters used. This is usually equal to `numberOfParameters`.
     */
    open func apply(using parameters: [String]) throws -> UInt {
        return try applyBlock(parameters)
    }

    open var displayName : String? {
        if let name {
            return "--\(name)"
        }
        if let shortName {
            return "-\(shortName)"
        }
        return nil
    }

    open var errorName : String {
        if let name = displayName {
            return name
        }
        if let shortHelp {
            return shortHelp
        }
        return "anonymous"
    }

    open override var description: String {
        return "<\(descriptionPrefix): \(displayHelp)>"
    }

    public enum HelpStyle {
        case summary    /// The short help, but including whether to the argument is optional.
        case short      /// The short help
        case long       /// The long form help
    }

    open func help(inStyle style: HelpStyle, width: UInt = 80) -> String {
        var possible = ""
        if style == .long {
            possible += "   " + help(inStyle: .short)
            if let help {
                if possible.count >= 19 {
                    possible += "\n" + String(padding: 20)
                } else {
                    possible += String(padding: 20 - possible.count)
                }
                possible += help.byWrapping(to: Int(width) - 20, firstLinePrefix: "", prefix: String(padding: 20))
            }
            possible += "\n"
        } else {
            if let displayName {
                if style == .summary {
                    if required {
                        possible += "<"
                    } else {
                        possible += "["
                    }
                }
                if let shortName, style == .short {
                    possible += "-" + shortName + "|"
                }
                possible += displayName
                if let shortHelp {
                    possible += " "
                    possible += shortHelp
                }
                if style == .summary {
                    if required {
                        possible += ">"
                    } else {
                        possible += "]"
                    }
                }
            } else {
                if let shortHelp {
                    if style == .summary {
                        if required {
                            possible += "<"
                        } else {
                            possible += "["
                        }
                    }
                    possible += shortHelp
                    if style == .summary {
                        if required {
                            possible += ">"
                        } else {
                            possible += "]"
                        }
                    }
                }
            }
        }
        return possible
    }

    open var displayHelp : String {
        return help(inStyle: .summary)
    }

}

@objcMembers
open class AJRTypedCommandLineArgument<T:LosslessStringConvertible> : AJRCommandLineArgument {

    public init(name: String? = nil,
                shortName: String? = nil,
                help: String? = nil,
                shortHelp: String? = nil,
                repeatCount: UInt? = 1,
                required: Bool = false,
                numberOfParameters: UInt? = nil,
                block: @escaping (_ values: [T]) throws -> UInt) {
        // This basically just springboards us to a re-typed block.
        super.init(name: name,
                   shortName: shortName,
                   help: help,
                   shortHelp: shortHelp,
                   repeatCount: repeatCount,
                   required: required,
                   numberOfParameters: numberOfParameters,
                   block: { values in
            if let values = values as? [T] {
                return try block(values)
            }
            return 0
        })
    }

    public convenience init(name: String? = nil,
                            shortName: String? = nil,
                            help: String? = nil,
                            shortHelp: String? = nil,
                            repeatCount: UInt? = 1,
                            required: Bool = false,
                            block: @escaping (_ value: T) throws -> Void) {
        // This basically just springboards us to a re-typed block.
        self.init(name: name,
                  shortName: shortName,
                  help: help,
                  shortHelp: shortHelp,
                  repeatCount: repeatCount,
                  required: required,
                  numberOfParameters: 1,
                  block: { values in
            try block(values[0])
            return 1
        })
    }

    public convenience init(name: String? = nil,
                            shortName: String? = nil,
                            help: String? = nil,
                            shortHelp: String? = nil,
                            repeatCount: UInt? = 1,
                            required: Bool = false,
                            block: @escaping () throws -> Void) {
        // This basically just springboards us to a re-typed block.
        self.init(name: name,
                  shortName: shortName,
                  help: help,
                  shortHelp: shortHelp,
                  repeatCount: repeatCount,
                  required: required,
                  numberOfParameters: 0,
                  block: { values in
            try block()
            return 0
        })
    }

    open var typedApplyBlock : (_ values: [T]) throws -> UInt {
        return applyBlock as ((_ values: [T]) throws -> UInt)
    }

    open override func apply(using parameters: [String]) throws -> UInt {
        var result : UInt = 0

        // If we have a known number of parameters, then we'll just convert that many.
        if let numberOfParameters {
            // Well, in the case of 0, we'll just call with an empty array.
            if numberOfParameters == 0 {
                result = try typedApplyBlock([] as [T])
            } else {
                // We do this differently than below, because we expect an exact number of parameters, which means they all have to convert to the correct type.
                var converted = [T]()
                for raw in parameters {
                    if let value = T.init(raw) {
                        converted.append(value)
                    } else {
                        throw AJRMain.Error.invalidArgument("Unable to convert the input value \"raw\" into the expected type: \"\(type(of:T.self))\"")
                    }
                }
                result = try typedApplyBlock(converted)
            }
        } else {
            // We'll convert as many argument as possible to the expected type.
            var converted = [T]()
            for raw in parameters {
                if let value = T.init(raw) {
                    converted.append(value)
                } else {
                    // Unlike above, when we can't convert an argument, we'll just stop converting. If we didn't get enough, that'll be up to the caller to deal with.
                    break
                }
                result = try typedApplyBlock(converted)
            }
        }
        return result

    }

}

@propertyWrapper
open class AJRCLArgument<Value> {

    private var value : Value? = nil

    public static subscript<EditableOwner: AJREditableObject>(
        _enclosingInstance instance: EditableOwner,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EditableOwner, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EditableOwner, AJRCLArgument>
    ) -> Value {
        get {
            return instance[keyPath: storageKeyPath].value!
        }
        set {
            // Now store the new value.
            instance[keyPath: storageKeyPath].value = newValue
        }
    }

    @available(*, unavailable, message: "@AJRCLArgument can only be applied to classes.")
    public var wrappedValue : Value {
        get { fatalError("You called @AJRCLArgument's getter, which shouldn't be possible.") }
        set { fatalError("You called @AJRCLArgument's setter, which shouldn't be possible.") }
    }

    public init(wrappedValue: Value, key: String) {
        self.value = wrappedValue
    }

}
