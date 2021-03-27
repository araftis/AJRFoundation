
import Foundation

public func AJRClamp<T:Comparable>(_ valueIn: T, min: T, max: T) -> T {
    var value : T = valueIn
    
    if value < min {
        value = min
    }
    if value > max {
        value = max
    }
    
    return value
}

public struct AJRFileNameMatchOptions : OptionSet {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    /**
     Normally, every occurrence of a backslash (`\') followed by a character in pattern is replaced by that character.  This is done to negate any special meaning for
     the character.  If the FNM_NOESCAPE flag is set, a backslash character is treated as an ordinary character.
     */
    static let noescape = AJRFileNameMatchOptions(rawValue: FNM_NOESCAPE)
     /**
     Slash characters in string must be explicitly matched by slashes in pattern.  If this flag is not set, then slashes are treated as regular characters.
     */
    static let pathname = AJRFileNameMatchOptions(rawValue: FNM_PATHNAME)
    /**
    Leading periods in strings match periods in patterns.  The definition of *leading* is related to the specification of `FNM_PATHNAME`. A period is always *leading* if it is the first character in string.  Additionally, if `FNM_PATHNAME` is set, a period is *leading* if it immediately follows a slash.
    */
    static let period = AJRFileNameMatchOptions(rawValue: FNM_PERIOD)
    static let fileName = AJRFileNameMatchOptions(rawValue: FNM_FILE_NAME)
    static let leadingDir = AJRFileNameMatchOptions(rawValue: FNM_LEADING_DIR)
    /**
     Ignore case.
     */
    static let casefold = AJRFileNameMatchOptions(rawValue: FNM_CASEFOLD)
    /**
     Ignore case.
     */
    static let ignoreCase = AJRFileNameMatchOptions(rawValue: FNM_IGNORECASE)
    
}

/**
 Front-ends fnmatch to make it easier to work with, since that c-function requires pointers to C strings, which can make the code calling into it a little ugly.'
 
 - See Also: The man page for fnmatch()
 
 - parameter pattern:The pattern to match. For example, something like "*.*".
 - parameter in: The String to match against, for example "filename.txt".
 - parameter options: The search  options.
 
 - returns: `true` if the input string, `in` matches `pattern`.
 */
public func AJRFileNameMatch(pattern patternIn: String, in stringIn: String, options: AJRFileNameMatchOptions) -> Bool {
    var pattern = patternIn
    var string = stringIn
    return pattern.withUTF8 { (patternUTF8) -> Bool in
        return patternUTF8.withMemoryRebound(to: Int8.self) { (castPattern) -> Bool in
            return string.withUTF8 { (stringUTF8) -> Bool in
                return stringUTF8.withMemoryRebound(to: Int8.self) { (castString) -> Bool in
                    return fnmatch(castPattern.baseAddress, castString.baseAddress, options.rawValue) == 0
                }
            }
        }
    }
}

public func AJRDateFromString(_ string : String, _ calendar: Calendar?) throws -> Date {
    var error : NSError? = nil
    if let date = AJRDateFromString(string, calendar, &error) {
        return date
    }
    throw error!
}

