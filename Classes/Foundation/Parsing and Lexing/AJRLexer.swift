//
//  AJRLexer.swift
//  AJRLanguage
//
//  Created by AJ Raftis on 11/3/20.
//

import Foundation
import OrderedCollections

public enum AJRLexerError : Error {
    case noRegisteredActions
    case unknownText(String)
    case invalidPattern(String)
    case invalidInput(String)
    case unmatchedParentheses(String)
    case invalidPath(String)
    case invalidURL(String)
    case invalidLexer(String)
}

public typealias AJRLexerAction = (String, NSRange) throws -> Void

open class AJRLexer: NSObject {

    open var patterns = Dictionary<String,AJRPattern>()
    open var actions = OrderedDictionary<String,AJRLexerAction>()

    public override init() {
    }
    
    public convenience init(url: URL) throws {
        self.init()
        try read(from: url)
    }

    public convenience init(path: String) throws {
        self.init()
        try read(from: path)
    }

    public convenience init(stream: InputStream) throws {
        self.init()
        try read(from: stream)
    }
    
    public convenience init(lexer name: String) throws {
        self.init()
        try read(lexer: name)
    }

    // MARK: - Patterns

    open func addPattern(_ pattern : AJRPattern) -> Void {
        patterns[pattern.identifier] = pattern
    }

    @discardableResult open func addPattern(_ rawPattern : String, named name: String, at lineNumber: Int? = nil) throws -> AJRPattern {
        let pattern = AJRPattern(lineNumber: lineNumber, identifier: name, pattern: rawPattern, lexer: self)
        addPattern(pattern)
        return pattern
    }

    open func pattern(named name: String) -> AJRPattern? {
        return patterns[name]
    }

    open func associate(pattern: AJRPattern, to action: @escaping AJRLexerAction) -> Void {
        actions[pattern.identifier] = action
    }

    open func associate(name: String, to action: @escaping AJRLexerAction) -> Void {
        if let pattern = patterns[name] {
            associate(pattern: pattern, to: action)
        }
    }

    // MARK: - Lexing

    internal func buildInclusiveRegularExpression() throws -> NSRegularExpression {
        var fullExpression = ""

        if actions.count == 0 {
            throw AJRLexerError.noRegisteredActions
        }

        for (key, _) in actions {
            guard let basePattern = patterns[key] else { continue }
            if let pattern = basePattern.pattern {
                //print("Adding: \(key): \(pattern)")
                // Doing this in the subpattern tells the regex the subexpression that all of it's subexpressions are not to be counting the the numberOfCaptures.
                var subpattern = pattern.replacingOccurrences(of: "(", with: "(?:")
                // Basically \( gets replaced, so if we wind up with \(?:, then replace back to \(.
                subpattern = subpattern.replacingOccurrences(of: "\\(?:", with: "\\(")
                //print("\(key) = r\"\(subpattern)\"")
                if fullExpression.isEmpty {
                    fullExpression = "(\(subpattern))"
                } else {
                    fullExpression += "|(\(subpattern))"
                }
            } else {
                if let error = basePattern.error {
                    throw AJRLexerError.invalidPattern("Pattern failed to produce a regular expression: \(error): at: \(key)\(basePattern.lineNumberString)")
                } else {
                    throw AJRLexerError.invalidPattern("Pattern failed to produce a regular expression at: \(key)\(basePattern.lineNumberString)")
                }
            }
        }

        //print("Matching against: \(fullExpression)")
        return try NSRegularExpression(pattern: fullExpression, options: [])
    }

    open func lex(string: String) throws -> Void {
        let regularExpression = try buildInclusiveRegularExpression()

        //print(regularExpression)

        var lastRange : NSRange? = nil
        var foundError : Error? = nil
        regularExpression.enumerateMatches(in: string, options: [], range: string.fullNSRange) { (result, flags, stop) in
            var matchIndex : Int? = nil
            var matchRange : NSRange? = nil
            for x in 0...regularExpression.numberOfCaptureGroups {
                let range = result!.range(at: x)
                if range.location != NSNotFound {
                    matchIndex = x - 1
                    matchRange = result!.range(at: x)
                }
            }
            if let lastRange = lastRange, let matchRange = matchRange {
                let subrange = NSRange(location: lastRange.upperBound, length: matchRange.lowerBound - lastRange.upperBound)
                if subrange.length > 0 {
                    let otherText = string[subrange].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !otherText.isEmpty {
                        foundError = AJRLexerError.unknownText("Unknown text in input: \(otherText)")
                        stop.pointee = true
                    }
                }
            }
            if foundError == nil {
                if let matchIndex = matchIndex, let matchRange = matchRange {
                    let key = actions.elements[matchIndex].key
                    let callback = actions[key]
                    let substring = string[matchRange]
                    //print("found: \(substring), matched by: \(key)")
                    if let callback = callback {
                        // Should never be null, but let's be safe and not force unwrap.
                        do {
                            try callback(String(substring), matchRange)
                        } catch {
                            foundError = error
                            stop.pointee = true
                        }
                    }
                }
                lastRange = matchRange
            }
        }
        if foundError == nil, let lastRange = lastRange {
            let otherText = string.suffix(string.utf16.count - lastRange.upperBound)
            if otherText.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted) != nil {
                foundError = AJRLexerError.unknownText("Unknown text in input: \"\(otherText)\"")
            }
        }
        if let error = foundError {
            throw error
        }
    }
    
    // MARK: - I/O
    
    open func read(from path: String) throws {
        if let inputStream = InputStream(fileAtPath: path) {
            try read(from: inputStream)
        } else {
            throw AJRLexerError.invalidPath("Unable to read from file: \(path)")
        }
    }
    
    open func read(from url: URL) throws {
        if let inputStream = InputStream(url: url) {
            try read(from: inputStream)
        } else {
            throw AJRLexerError.invalidURL("Unable to read from URL: \(url)")
        }
    }
    
    open func read(from data: Data) throws {
        let inputStream = InputStream(data: data)
        try read(from: inputStream)
    }
    
    open func read(lexer name: String) throws {
        var path = Bundle.main.path(forResource: name, ofType: "lexer")
        if path == nil {
            path = Bundle(for: type(of:self)).path(forResource: name, ofType: "lexer")
        }
        if let path {
            try read(from: path)
        } else {
            throw AJRLexerError.invalidLexer("Could not find a lexer named \"\(name)\"")
        }
    }
    
    /**
     This is a super simple file reader. Basically, we read each line of the input stream. For each line that starts with a `name =` we record the name and then start a buffer of everything after the equals. We then read lines until we find another one like the above. All empty lines are ignored and all lines that start with `//` are ignored.
     
     The lines themselves are basically named regular expressions. Note that expressions can refer to other expression by name by surround the name with braces. If what's surrounded by braces is `uXXXXXXXX` where X is a hexadicimal value, then the substring is replaced with the unicode equivalent.
     */
    private static let identifierExpression = try! NSRegularExpression(pattern: "[A-Za-z_][A-Za-z_-]* *→ *")
    private static let identifierOnlyExpression = try! NSRegularExpression(pattern: "[A-Za-z_][A-Za-z_-]*")
    private static let commentExpression = try! NSRegularExpression(pattern: "^ *//.*$")
    open func read(from stream: InputStream) throws {
        if stream.streamStatus != .open {
            stream.open()
        }
        var lineNumber = 1
        var rules : OrderedDictionary<String,String> = OrderedDictionary<String,String>()
        var lines = [String:Int]()

        let addBody : (String?, String?, Int) -> Void = { name, body, lineStart in
            if let name, let body {
                if let currentBody = rules[name] {
                    rules[name] = currentBody + "|(\(body))"
                } else {
                    rules[name] = "(\(body))"
                    lines[name] = lineStart
                }
            }
        }
        
        var name : String? = nil
        var body : String? = nil
        var declaredLineStarted = 0
        while let line = try stream.readLine()?.trimmingCharacters(in: .whitespaces) {
            if !line.isEmpty {
                var range = AJRLexer.commentExpression.rangeOfFirstMatch(in: line, range: line.fullNSRange)
                if range.location != NSNotFound {
                    // We can just ignore this line.
                    print("comment: \(line)")
                } else {
                    range = AJRLexer.identifierExpression.rangeOfFirstMatch(in: line, range: line.fullNSRange)
                    if range.location != NSNotFound {
                        // Let's see if we're already doing name...
                        addBody(name, body, declaredLineStarted)

                        // Now get the info for the next rule.
                        let identifierRange = AJRLexer.identifierOnlyExpression.rangeOfFirstMatch(in: line, range: range)
                        declaredLineStarted = lineNumber
                        name = String(line[identifierRange])
                        body = String(line[NSRange(location: range.upperBound, length: line.count - range.upperBound)])
                    } else {
                        // We have to append to buffer.
                        if body != nil {
                            body! += line
                        }
                    }
                }
            }
            lineNumber += 1
        }
        // If we have a declaration hanging, this will add it.
        addBody(name, body, declaredLineStarted)
        for (name, body) in rules {
            print("adding: \(name) at: \(lineNumber)")
            try addPattern(body, named: name, at: lineNumber)
        }
    }
    
}
