//
//  AJRLexerTests.swift
//  AJRFoundationTests
//
//  Created by AJ Raftis on 3/16/23.
//

import XCTest

@testable import AJRFoundation

final class AJRLexerTests: XCTestCase {

    func testRead() throws {
        do {
            // Read a lexer
            let lexer = try AJRLexer(lexer: "Swift")
            print("lexer: \(lexer)")
            
            // Associate actions to our created patterns
            lexer.associate(name: "open_paren") { value, range in
                print("open_paren \(range): \(value)")
            }
            lexer.associate(name: "close_paren") { value, range in
                print("close_paren \(range): \(value)")
            }
            lexer.associate(name: "numeric-literal") { value, range in
                print("numeric \(range): \(value)")
            }
            lexer.associate(name: "string-literal") { value, range in
                print("string \(range): \(value)")
            }
            lexer.associate(name: "id") { value, range in
                print("id \(range): \(value)")
            }
            lexer.associate(name: "operator") { value, range in
                print("operator \(range): \(value)")
            }

            // And see if we can build an actual expression.
//            let expression = try lexer.buildInclusiveRegularExpression()
//            print("expression: \(expression)")
//
            try lexer.lex(string: "alex + john - (raftis) on 6/16/19.71 is \"birthday\"")
        } catch {
            print("failed: \(error)")
        }
    }

}
