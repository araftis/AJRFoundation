/*
 AJRFunctionExpression.swift
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

@objcMembers
open class AJRFunctionExpression : AJRExpression {

    // MARK: - Properties

    // NOTE: The force unwraps here are present, because we have to be able to init in an uninitialized state.
    open var function : AJRFunction!
    open var arguments : AJRArguments!

    // MARK: - Creation

    public required init() {
        super.init()
    }

    public init(function: AJRFunction, arguments: [AJREvaluation]) {
        self.function = function
        self.arguments = AJRArguments(arguments: arguments)
        super.init()
        self.arguments.functionExpression = self
    }

    // MARK: - AJRExpression

    public override func evaluate(with context: AJREvaluationContext) throws -> Any {
        let frame = AJRStackFrame(arguments: arguments)
        context.push(stackFrame: frame);
        defer {
            context.pop()
        }
        let result = try function.evaluate(with: context)

        return result
    }

    // MARK: - CustomStringConvertible

    public override var description : String {
        var description = ""

        description += function.name
        description += "("
        for (index, argument) in arguments.enumerated() {
            if index > 0 {
                description += ", "
            }
            description += argument.description
        }
        description += ")"

        return description
    }

    public override func isEqual(_ other: Any?) -> Bool {
        if let typed = other as? AJRFunctionExpression {
            return (super.isEqual(other)
                && AJRAnyEquals(function, typed.function)
            )
        }
        return false;
    }

    // MARK: - NSCoding

    public required init?(coder: NSCoder) {
        if let function = coder.decodeObject(forKey: "function") as? AJRFunction {
            self.function = function
        } else {
            return nil
        }
        if let arguments = coder.decodeObject(forKey: "arguments") as? AJRArguments {
            self.arguments = arguments
        } else {
            return nil
        }
        super.init(coder:coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(function, forKey: "function")
        coder.encode(arguments, forKey: "arguments")
    }

    // MARK: - AJRXMLCoding

    public override func decode(with coder: AJRXMLCoder) {
        super.decode(with: coder)
        coder.decodeObject(forKey: "function") { value in
            if let value = value as? AJRFunction {
                self.function = value
            }
        }
        coder.decodeObject(forKey: "arguments") { value in
            if let value = value as? AJRArguments {
                self.arguments = value
            }
        }
    }

    public override func encode(with coder: AJRXMLCoder) {
        super.encode(with: coder)
        coder.encode(function, forKey: "function")
        coder.encode(arguments, forKey: "arguments")
    }

}
