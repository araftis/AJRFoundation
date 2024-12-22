//
//  AJRMain.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 4/29/23.
//

import Cocoa

public extension Notification.Name {

    static var mainWillRun = Self("AJRMainWillRunNotification")
    static var mainDidRun = Self("AJRMainDidRunNotification")
    static var mainWillTerminate = Self("AJRMainWillTerminateNotification")
    static var mainWillProcessArguments = Self("AJRMainWillProcessArgumentsNotification")
    static var mainDidProcessArguments = Self("AJRMainDidProcessArgumentsNotification")

}

public let AJRMainTerminationCodeKey = "AJRMainTerminationCodeKey"

public func AJRPrint(_ string: String, flush: Bool = true) -> Void {
    AJRMain.print(.stdout, string, flush: flush)
}

public func AJRPrint(_ output: AJRMain.Output = .stdout, _ string: String, flush: Bool = true) -> Void {
    AJRMain.print(output, string, flush: flush)
}

@objcMembers
open class AJRMain: NSObject {

    public enum Error : Swift.Error {

        case invalidArgument(String)

    }

    // MARK: - Class Properies

    public static var `default` : AJRMain! = nil

    // MARK: - Properties

    /// An array of command line arguments. These are maintained in the ordered registered, and searched in the order registered in case order matters for your arguments.
    open var arguments = [AJRCommandLineArgument]()
    /// This is initialized with the current time when `begin()` is called, but before `willRun()` is called.
    open private(set) var startTime : Date?
    /// Holds the termination code. You don't set this directly. Instead, call terminate(exitCode:)
    open private(set) var exitCode : Int32 = 0
    /// Maintains a counting semaphore initialized to 1. This is used by the main run loop, which will run until something calls the `terminate(exitCode:)` method or your `run()` method exits, in which case `terminate(exitCode:)` is called with an `exitCode` or 0.
    public var semaphore : AJRCountdownSemaphore? = nil
    /// Determines the priority for the primary worker thread. The default is `.default`. This is not settable, but you can override it from your subclass if you want your main run loop to run with a different priority.
    open var priority : DispatchQoS.QoSClass {
        return .default
    }

    // MARK: - Creation

    /**
     Initializing your main. Note that the superclass doesn't nothing, but you should override `init()` and register your command line arguments. Note that you don't have to have command line arguments, but you'll still need to override this method.
     */
    public required override init() {
        super.init()
        AJRMain.default = self
    }

    // MARK: - Notification Points

    /**
     Called when you main is about to start running. If overridden, you must call super.
     */
    open func willRun() {
        NotificationCenter.default.post(name: .mainWillRun, object: self)
    }

    /**
     Called when you main is about to exit. If overridden, you must call super.
     */
    open func didRun() {
        NotificationCenter.default.post(name: .mainDidRun, object: self, userInfo: [AJRMainTerminationCodeKey:exitCode])
    }

    /**
     Called when the app is about to terminate. If you override this method, you _must_ call super's implementation.

     - Parameter exitCode: The exit code. This is generally 0 to indicate no issues, and something else otherwise, but in the end, the value is user defined, so it might be anything.
     */
    open func willTerminate(exitCode: Int32) {
        self.exitCode = exitCode
        NotificationCenter.default.post(name: .mainWillTerminate, object: self, userInfo: [AJRMainTerminationCodeKey:exitCode])
    }

    /**
     Called when arguments are about to be processed. If you haven't registered arguments yet, you better register them now.
     */
    open func willProcessArguments() {
        add(argument: AJRTypedCommandLineArgument<String>(name: "help",
                                                          shortName: "h",
                                                          help: "Run in test mode, which shows all the renames without actually renaming the files.") {
            self.usage()
        })

        NotificationCenter.default.post(name: .mainWillProcessArguments, object: self)
    }

    /**
     Called when all arguments have been processed.

     This is you last chance to do any sanity checking prior to you application actually beginning to run.

     Note that if the arguments fail to process do to an error, this method may not be called.
     */
    open func didProcessArguments() {
        NotificationCenter.default.post(name: .mainDidProcessArguments, object: self)
    }

    // MARK: - Command Line Arguments

    /**
     Adds an argument to be processed.

     - Parameter argument: The argument being added.
     */
    open func add(argument: AJRCommandLineArgument) {
        for existing in arguments {
            if (argument.name != nil && AJRAnyEquals(argument.name, existing.name))
                || (argument.shortName != nil && AJRAnyEquals(argument.shortName, existing.shortName)) {
                usage(error: "An argument \(existing.help(inStyle: .short)) has already been registered", exitCode: 1)
                exit(1)
            }
        }
        arguments.append(argument)
    }

    internal func nextArgument(passingNameTest nameTest: (_ argument: AJRCommandLineArgument) -> Bool) -> AJRCommandLineArgument? {
        for argument in arguments {
            if nameTest(argument) {
                if let repeatCount = argument.repeatCount, argument.usedCount < repeatCount {
                    return argument
                } else if argument.repeatCount == nil {
                    return argument
                }
            }
        }
        return nil
    }

    /**
     Returns the next available argument for the given name. This can repeat if the argument can be repeated.

     Unlike the `nextArgumentWithShortName(_:)` method, this `name` may be `nil`, which means returns an argument not associated with a name. This happens when you have a command line like:

     ```
     MyCommand -output test.output test.input
     ```

     In this case, we have two arguments, one named, one unnamed. In this case, the `test.input` argument return would be the first unnamed argument that's not passed it `repeatCount`.

     - Parameter name: The `name` of the argument. This looks for arguments of the type `--help`.

     - Returns: The argument one is found, otherwise `nil`.
     */
    open func nextArgumentWithName(_ name: (any StringProtocol)?) -> AJRCommandLineArgument? {
        return nextArgument { argument in
            return ((name == nil && argument.name == nil && argument.shortName == nil)
                    || (name != nil && AJRAnyEquals(argument.name, name)))
        }
    }

    /**
     Returns the next available argument for the given short name. This can repeat if the argument can be repeated.

     - Parameter shortName: The `shortName` of the argument. This looks for arguments of the type `-h`.

     - Returns: The argument one is found, otherwise `nil`.
     */
    open func nextArgumentWithShortName(_ shortName: any StringProtocol) -> AJRCommandLineArgument? {
        return nextArgument { argument in
            return AJRAnyEquals(argument.shortName, shortName)
        }
    }

    /**
     Processes a single argument from the command line.

     If an error is encountered, and `terminate(exitCode:)` is called, this method may never exit.

     - Parameter argument: The argument to be processed.
     - Parameter remaining: A subarray of the remaining arguments on the command line.

     - Returns: The number of arguments consumed.
     */
    open func process(argument: String, remaining: ArraySlice<String>) throws -> UInt {
        var nextArgument : AJRCommandLineArgument? = nil
        var consumed : UInt = 0

        if argument.hasPrefix("--") {
            nextArgument = nextArgumentWithName(argument.suffix(argument.count - 2))
            // Note that we consumed an argument
            consumed = 1
        } else if argument.hasPrefix("-") {
            nextArgument = nextArgumentWithShortName(argument[argument.index(argument.startIndex, offsetBy: 1) ..< argument.endIndex])
            // Note that we consumed an argument.
            consumed = 1
        } else {
            // In this case, we didn't consume an argument, because we're the unnamed case.
            nextArgument = nextArgumentWithName(nil)
        }
        if let nextArgument {
            //print("argument: \(nextArgument)\n")
            if let numberOfParameters = nextArgument.numberOfParameters,
               numberOfParameters > 0 {
                if numberOfParameters + consumed > remaining.count {
                    // We weren't passed sufficient arguments
                    throw AJRMain.Error.invalidArgument("Insufficient arguments passed to \(nextArgument.errorName).")
                }
                let parameters = Array(remaining[remaining.startIndex + Int(consumed) ..< remaining.startIndex + Int(consumed + numberOfParameters)])
                consumed += try nextArgument.apply(using: parameters)
            } else {
                // We don't have any arguments, so call with an empty array.
                consumed += try nextArgument.apply(using: [])
            }
        } else {
            throw AJRMain.Error.invalidArgument("Unknown argument: \(argument)")
        }

        return consumed
    }

    /**
     Processes the command line arguments.

     This will be called on the same worker thread that will eventually call `run()`,  so if you choose to do your work here, you may. For example, say you allow multiple input paths and you want to process each input path as it's parsed on the command line. That's reasonable to do, because this is on the worker thread.

     Because this is on the worker thread, if an error is encountered while processing the arguments, then the `terminate(exitexitCode:)` method will be called.
     */
    open func processArguments() throws {
        willProcessArguments()

        let rawArguments = ProcessInfo.processInfo.arguments
        var index = rawArguments.startIndex
        // We'll skip over the first, because it's the name of the process, and we can actually get that from ProcessInfo.
        index = index.advanced(by: 1)
        var arguments = rawArguments[index ..< rawArguments.endIndex]
        while arguments.count > 0 {
            // It's safe to force unwrap, because we checked the argument count.
            let argument = arguments.first!
            // Get all the arguments.
            arguments = rawArguments[index ..< rawArguments.endIndex]
            let consumed = try process(argument: argument, remaining: arguments)
            // If we consumed something, we'll need to increment our array
            if consumed > 0 {
                index = index.advanced(by: Int(consumed))
                // Nibble off the first argument(s).
                arguments = rawArguments[index ..< rawArguments.endIndex]
            }
        }

        didProcessArguments()
    }

    // MARK: - Running

    /**
     This is the primary override point for you code. At the point where this method is called, you
     */
    public static func main() {
        let main = Self.init()
        main.begin()
        exit(main.exitCode)
    }

    /**
     This is a primary override points, and you should override this method to do your work. When this method is called, you main class will be instantiated, and the arguments processed.
     */
    open func run() -> Void {
    }

    /**
     Spins up a run loop and calls `run()`, which is what you should override for your code. You'll generally never override this method.
     */
    open func begin() {
        // Record that we're starting
        startTime = Date()

        // Process our arguments, which happens before we flag that we're running.
        do {
            try processArguments()
        } catch AJRMain.Error.invalidArgument(let message) {
            usage(error: message, exitCode: 1)
            // And don't attempt to start up the run loop.
            return
        } catch {
            // This won't return
            usage(error: error.localizedDescription, exitCode: 1)
            // And don't attempt to start up the run loop.
            return
        }

        // Create the termination semaphore. This will be signaled from terminate(exitCode:).
        semaphore = AJRCountdownSemaphore(count: 1)

        // Notify ourself and the world that we're about to run.
        willRun()

        // Launch a thread and call run.
        weak var weakSelf = self
        DispatchQueue.global(qos: priority).async {
            weakSelf?.run()
            // TODO: Not entirely thread safe, as this could result in calling the semaphore more than once, since it could also still be signalled from another child thread. We should add something like a
            if let self = weakSelf,
               let semaphore = self.semaphore,
               semaphore.count > 0 {
                // NOTE: None of this code may run, since terminate may be called from another thread.
                weakSelf?.terminate(exitCode: 0)
            }
        }

        RunLoop.main.spinRunLoop(inMode: .default, waitingFor: semaphore)

        // We're done with the semaphore, so nuke it.
        semaphore = nil

        // Finally tell ourself the world that we did run.
        didRun()
    }

    /**
     Call this method when your process is ready to terminate.

     You generally don't need to call this method, because if the  `run()` returns, then this method will be called with an exit code of 0. However, you can call this from any thread in your application, which will cause the run loop on the main thread to terminate, thus causing your application to terminate.
     */
    open func terminate(exitCode: Int32) -> Void {
        willTerminate(exitCode: exitCode)
        if let semaphore {
            semaphore.signal()
        } else {
            // This means we're not in our runloop, so just exit.
            exit(exitCode)
        }
    }

    // MARK: I/O

    public enum Output {
        case stdout
        case stderr
    }

    open class func print(_ string: String, flush: Bool = true) -> Void {
        self.print(.stdout, string, flush: flush)
    }

    open class func print(_ output: Output, _ string: String, flush: Bool = true) -> Void {
        let fileHandle : FileHandle
        switch output {
        case .stderr: fileHandle = FileHandle.standardError
        case .stdout: fileHandle = FileHandle.standardOutput
        }
        try? fileHandle.write(string)
        if flush {
            try? fileHandle.synchronize()
        }
    }

    open func print(_ string: String, flush: Bool = true) -> Void {
        AJRMain.print(.stdout, string, flush: flush)
    }

    open func print(_ output: Output, _ string: String, flush: Bool = true) -> Void {
        AJRMain.print(output, string, flush: flush)
    }

    // MARK: - Console

    /// Returns the width of the console. By default, the base class just returns 80.
    open var width: UInt {
        return 80
    }

    /// Returns the height of the console. By default, the base class just returns 24.
    open var height: UInt {
        return 24
    }

    // MARK: - Help

    open func usage(error: String? = nil, exitCode: Int32 = 1) {
        if let error {
            self.print(.stderr, "Error: \(error)\n")
        }
        var argumentsString = ""
        var requiredString = ""
        for argument in arguments {
            argumentsString += " "
            argumentsString += argument.displayHelp
            if argument.required {
                requiredString += " "
                requiredString += argument.displayHelp
            }
        }
        if (ProcessInfo.processInfo.processName.count + argumentsString.count) < width - 8 {
            self.print(.stderr, "Usage: \(ProcessInfo.processInfo.processName) \(argumentsString)\n")
        } else {
            self.print(.stderr, "Usage: \(ProcessInfo.processInfo.processName) [options] \(requiredString)\n")
        }

        if arguments.count > 0 {
//            print(.stderr, "00000000011111111112222222222333333333344444444445555555555666666666677777777778\n")
//            print(.stderr, "12345678901234567890123456789012345678901234567890123456789012345678901234567890\n")
            self.print(.stderr, "Options:\n")
            for argument in arguments {
                print(.stderr, argument.help(inStyle: .long, width: width))
            }
        }

        terminate(exitCode: exitCode)
    }
}
