/*
 AJRMain.m
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

#import <AJRFoundation/AJRMain.h>

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"

#import <sys/types.h>

NSString * const AJRMainWillRunNotification = @"AJRMainWillRunNotification";
NSString * const AJRMainDidRunNotification = @"AJRMainDidRunNotification";
NSString * const AJRMainWillTerminateNotification = @"AJRMainWillTerminateNotification";
NSString * const    AJRMainTerminateCodeKey = @"AJRMainTerminationCode";
NSString * const AJRMainWillProcessArgumentsNotification = @"AJRMainWillProcessArgumentsNotification";
NSString * const AJRMainDidProcessArgumentsNotification = @"AJRMainDidProcessArgumentsNotification";

typedef void (*assignalHandler)(int);

static assignalHandler _assignalHandlers[32];

AJRMain *ajrMain;

int AJRToolMain(NSString *className, int argc, const char *argv[]) {
    int result = 0;
    
    @autoreleasepool {
        AJRMain *mainObject;
        Class class;
        
        class = NSClassFromString(className);
        if (!class) {
            AJRPrintf(@"Unable to find class named: %@\n", className);
            result = -1;
        } else {
            mainObject = [[class alloc] init];
            [mainObject begin];
        }
    }
    
    return result;
}

/* Handling CTRL-C */

@interface AJRMain (AJRPrivate)

- (BOOL)_processSignal:(int)signal;

@end

static void _ajrMainHandlerRoutine(int signalRaised) {
    [ajrMain _processSignal:signalRaised];
}

static void _attachStreams(void) {
    AJRStdErr = [NSFileHandle fileHandleWithStandardError];
    AJRStdOut = [NSFileHandle fileHandleWithStandardOutput];
    AJRStdIn = [NSFileHandle fileHandleWithStandardInput];
}

@implementation AJRCmndArg

+ (instancetype)commandWithArgument:(NSString *)argument
                         parameters:(nullable NSArray<NSString *> *)parameters
                     processorBlock:(AJRArgumentProcessorBlock)processorBlock
                               help:(NSString *)help
                            repeats:(BOOL)repeats
                           required:(BOOL)required {
    return [[self alloc] initArgument:argument parameters:parameters processorBlock:processorBlock help:help repeats:repeats required:required];
}

typedef void (*AJRVoidImp)(id self, SEL _cmd);

static AJRArgumentProcessorBlock AJRGetProcessorBlockForParamterOfType(AJRArgumentType type, NSString *argument, NSString *parameter, NSString *property) {
    return ^(id target, NSArray<NSString *> *arguments) {
        NSInteger consumed = 0;
        NSString *next = nil;
        
        if (type != AJRArgumentTypeVoid) {
            next = [arguments firstObject];
            if (next == nil) {
                consumed = -1;
            }
        }
        
        if (consumed >= 0) {
            switch (type) {
                case AJRArgumentTypeVoid: {
                    AJRVoidImp imp = (AJRVoidImp)[target methodForSelector:NSSelectorFromString(property)];
                    if (imp) {
                        imp(target, NSSelectorFromString(property));
                    }
                    consumed = 0;
                    break;
                }
                case AJRArgumentTypeBoolean:
                    if (parameter) {
                        [target setValue:@([next boolValue]) forKey:property];
                        consumed = 1;
                    } else {
                        [target setValue:@YES forKey:property];
                        consumed = 1;
                    }
                    break;
                    
                case AJRArgumentTypeLong:
                    if (parameter) {
                        [target setValue:@([next longValue]) forKey:property];
                        consumed = 1;
                    }
                    break;
                    
                case AJRArgumentTypeLongLong:
                    if (parameter) {
                        [target setValue:@([next longLongValue]) forKey:property];
                        consumed = 1;
                    }
                    break;
                    
                case AJRArgumentTypeInteger:
                    if (parameter) {
                        [target setValue:@([next integerValue]) forKey:property];
                        consumed = 1;
                    }
                    break;
                    
                case AJRArgumentTypeFloat:
                    if (parameter) {
                        [target setValue:@([next floatValue]) forKey:property];
                        consumed = 1;
                    }

                case AJRArgumentTypeDouble:
                    if (parameter) {
                        [target setValue:@([next doubleValue]) forKey:property];
                        consumed = 1;
                    }
                    break;
                    
                case AJRArgumentTypeCharacter:
                    if (parameter) {
                        if ([next length]) {
                            [target setValue:@([next characterAtIndex:0]) forKey:property];
                            consumed = 1;
                        } else {
                            consumed = -1;
                        }
                    }
                    break;
                    
                case AJRArgumentTypeString: {
                    if ((parameter == nil) && (argument == nil)) {
                        [target setValue:next forKey:property];
                        consumed = 1;
                    } else if (parameter && (argument == nil)) {
                        [target setValue:next forKey:property];
                        consumed = 1;
                    } else if (parameter) {
                        [target setValue:next forKey:property];
                        consumed = 1;
                    }
                    break;
                }
            }
        }
        
        return consumed;
    };
}

+ (instancetype)commandWithArgument:(NSString *)argument
                          parameter:(nullable NSString *)parameter
                               type:(AJRArgumentType)type
                           property:(nullable NSString *)property
                               help:(NSString *)help
                            repeats:(BOOL)repeats
                           required:(BOOL)required {
    return [[self alloc] initArgument:argument
                           parameters:parameter ? @[parameter] : nil
                       processorBlock:AJRGetProcessorBlockForParamterOfType(type, argument, parameter, property)
                                 help:help
                              repeats:repeats
                             required:required];
}

- (instancetype)initArgument:(NSString *)argument
                  parameters:(nullable NSArray<NSString *> *)parameters
              processorBlock:(AJRArgumentProcessorBlock)processorBlock
                        help:(NSString *)help
                     repeats:(BOOL)repeats
                    required:(BOOL)required {
    if ((self = [super init])) {
        _argument = argument;
        _parameters = [parameters copy];
        _processorBlock = processorBlock;
        _help = help;
        _repeats = repeats;
        _used = NO;
        _required = required;
    }
    return self;
}

- (BOOL)isSingleArgument {
    return _argument == nil;
}

- (BOOL)isMatchFor:(NSString *)compare {
    if (!_argument) return NO;
    return [compare compare:_argument options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (NSInteger)processWithTarget:(id)target arguments:(NSArray<NSString *> *)arguments {
    return _processorBlock(target, arguments);
}

- (NSComparisonResult)compare:(id)other {
    NSString *p1, *p2;
    
    p1 = [self argument];
    p2 = [other argument];
    
    if (p1 && p2) return [p1 compare:p2];
    if (p1 && !p2) return NSOrderedDescending;
    if (!p1 && p2) return NSOrderedAscending;
    
    return NSOrderedSame;
}

@end

static NSLock *ioLock = nil;

@interface AJRMain ()

@property (nonatomic,strong) NSMutableArray<NSString *> *arguments;
@property (nonatomic,strong) NSMutableArray<AJRCmndArg *> *commandArguments;                    // Array of all valid arguments (AJRCmndArg)

@end

@implementation AJRMain
{
    NSMutableDictionary<NSString *, AJRCmndArg *> *_argumentIndex; // Index of arguments by "argument".
    NSDate *_startTime; // Time and date the process started.
}


+ (void)load {
    _attachStreams();
}

+ (void)initialize {
    ioLock = [[NSLock alloc] init];
}

- (void)emitError:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    AJRLog_fv(NSStringFromClass([self class]), AJRLogLevelError, format, ap);
    va_end(ap);
}

- (void)emitMessage:(NSString *)format, ... {
    va_list        ap;
    va_start(ap, format);
    AJRLog_fv(NSStringFromClass([self class]), AJRLogLevelInfo, format, ap);
    va_end(ap);
}

- (void)printArgDescription:(NSString*)description {
    if ([description length] < 61) {
        AJRPrintf(@" %@\n", description);
    } else {
        NSArray *words = [description componentsSeparatedByString:@" "];
        NSMutableString    *line = [NSMutableString string];
        NSEnumerator *enumerator = [words objectEnumerator];
        NSString *word;
        
        while ((word = [enumerator nextObject])) {
            if ([line length] + [word length] + 1 < 61) {
                [line appendFormat:@"%@ ", word];
            } else if ([line length] + [word length] + 1 == 61) {
                [line appendFormat:@"%@", word];
            } else {
                while (![word length]) {
                    if (!(word = [enumerator nextObject])) {
                        AJRPrintf(@" %@\n", line);
                        line = (NSMutableString *)[NSMutableString string];
                        break;
                    }
                }
                AJRPrintf(@" %@\n                  ", line);
                line = [NSMutableString stringWithFormat:@"%@ ", word];
            }
        }
        if ([line length]) {
            AJRPrintf(@" %@\n", line);
        }
    }
}

- (void)usage {
    NSUInteger x;
    AJRCmndArg *arg;
    NSString *argument;
    NSArray<NSString *> *parameters;
    NSArray *temp;
    
    AJRPrintf(@"\nUsage:%@", [self applicationName]);
    if ([_commandArguments count]) {
        AJRPrintf(@" [options]");
        for (x = 0; x < (const int)[_commandArguments count]; x++) {
            arg= [_commandArguments objectAtIndex:x];
            argument = [arg argument];
            parameters = [arg parameters];
            if ([parameters count] && !argument) {
                for (NSString *parameter in parameters) {
                    AJRPrintf(@" %@", parameter);
                }
            }
        }
        AJRPrintf(@"\n\n");
        AJRPrintf(@"Valid options are:\n");
        
        temp = [_commandArguments sortedArrayUsingSelector:@selector(compare:)];
        
        for (x = 0; x < (const int)[temp count]; x++) {
            NSString *compound;
            NSInteger fullLength;
            arg = [temp objectAtIndex:x];
            argument = [arg argument];
            parameters = [arg parameters];
            if ([parameters count] && !argument) {
                continue;
            } else if ([parameters count]) {
                compound = AJRFormat(@"--%@ %@", argument, [parameters componentsJoinedByString:@" "]);
                AJRPrintf(@"   %-15s", [compound UTF8String]);
                fullLength = [compound length];
            } else {
                AJRPrintf(@"   --%-13s", [argument UTF8String]);
                fullLength = [argument length];
            }
            if (fullLength > 15) {
                AJRPrintf(@"\n%*s", 18, "");
            }
            [self printArgDescription:[arg help]];
        }
        AJRPrintf(@"\n");
    } else {
        AJRPrintf(@"\n\n");
    }
    
    [self terminateWithExitCode:1];
}

- (instancetype)init {
    if ((self = [super init])) {
        ajrMain = self;
        
        _assignalHandlers[SIGHUP] = signal(SIGHUP, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGINT] = signal(SIGINT, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGQUIT] = signal(SIGQUIT, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGILL] = signal(SIGILL, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGTRAP] = signal(SIGTRAP, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGABRT] = signal(SIGABRT, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGEMT] = signal(SIGEMT, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGFPE] = signal(SIGFPE, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGKILL] = signal(SIGKILL, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGBUS] = signal(SIGBUS, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGSEGV] = signal(SIGSEGV, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGSYS] = signal(SIGSYS, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGPIPE] = signal(SIGPIPE, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGALRM] = signal(SIGALRM, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGTERM] = signal(SIGTERM, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGURG] = signal(SIGURG, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGSTOP] = signal(SIGSTOP, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGTSTP] = signal(SIGTSTP, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGCONT] = signal(SIGCONT, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGCHLD] = signal(SIGCHLD, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGTTIN] = signal(SIGTTIN, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGTTOU] = signal(SIGTTOU, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGIO] = signal(SIGIO, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGXCPU] = signal(SIGXCPU, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGXFSZ] = signal(SIGXFSZ, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGVTALRM] = signal(SIGVTALRM, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGPROF] = signal(SIGPROF, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGWINCH] = signal(SIGWINCH, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGINFO] = signal(SIGINFO, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGUSR1] = signal(SIGUSR1, _ajrMainHandlerRoutine);
        _assignalHandlers[SIGUSR2] = signal(SIGUSR2, _ajrMainHandlerRoutine);
        
        [self registerArgument:@"help"
                    parameters:nil
                processorBlock:^NSInteger(id  _Nonnull target, NSArray<NSString *> * _Nonnull arguments) {
            [self usage];
            return 0;
        }
                          help:@"Print this message"
                       repeats:NO
                      required:NO];
        [self registerArgument:@"logLevel"
                    parameters:@[@"<DEFAULT|EMERGENCY|ALERT|CRITICAL|ERROR|WARNING|NOTICE|INFO|DEBUG>"]
                processorBlock:^NSInteger(id  _Nonnull target, NSArray<NSString *> * _Nonnull arguments) {
            if ([arguments count]) {
                [self setLogLevel:AJRLogLevelFromString([arguments firstObject])];
                return 1;
            }
            return 0;
        }
                          help:@"Sets the log level of the process. The default is INFO, but lower levels will make the process quieter."
                       repeats:NO
                      required:NO];
        
        _startTime = [NSDate date];
        
        _processInformation = [NSProcessInfo processInfo];
        _applicationName = [_processInformation processName];
        _arguments = [[_processInformation arguments] mutableCopy];
        _applicationPath = [[[_arguments firstObject] stringByStandardizingPath] stringByDeletingLastPathComponent];
        
        _userName = NSUserName();
        _userHomeDirectory = NSHomeDirectory();
        
        _autoprocessArguments = YES;
    }
    
    return self;
}

- (void)processArguments {
    NSUInteger x, y, max = [_commandArguments count];
    AJRCmndArg *arg;
    NSString *cmnd;
    NSInteger argumentsConsumed = 0;
    NSInteger argumentCount = [_arguments count];
    
    [self willProcessArguments];
    
    for (x = 1; x < argumentCount; x++) {
        NSArray *subarguments = nil;
        if (x + 1 < argumentCount) {
            subarguments = [_arguments subarrayWithRange:(NSRange){x + 1, argumentCount - (x + 1)}];
        } else {
            subarguments = @[];
        }
        argumentsConsumed = 0;
        cmnd = [_arguments objectAtIndex:x];
        if ([cmnd hasPrefix:@"--"]) {
            arg = [_argumentIndex objectForKey:[cmnd substringFromIndex:2]];
            if (arg) {
                argumentsConsumed = [arg processWithTarget:self arguments:subarguments];
            } else {
                AJRLogError(@"Invalid argument:%@", cmnd);
                [self usage];
            }
        } else {
            for (y = 1; y < max; y++) {
                arg = [_commandArguments objectAtIndex:y];
                if ([arg isSingleArgument]) {
                    if ([arg used] && [arg repeats]) {
                        argumentsConsumed = [arg processWithTarget:self arguments:subarguments];
                        break;
                    } else {
                        argumentsConsumed = [arg processWithTarget:self arguments:subarguments];
                        break;
                    }
                }
            }
            if (y == max) {
                [self usage];
            }
        }
        if (argumentsConsumed == -1) {
            AJRLogError(@"Improper usage: %@", cmnd);
            [self usage];
            break;
        } else {
            x += argumentsConsumed;
        }
    }
    
    // Make sure all the arguments have been used.
    max = [_commandArguments count];
    for (x = 1; x < max; x++) {
        arg = [_commandArguments objectAtIndex:x];
        if ([arg isRequired] && ![arg used]) {
            [self usage];
        }
    }
    
    [self didProcessArguments];
}

- (AJRCmndArg *)registerArgument:(NSString *)argument
                     parameters:(nullable NSArray<NSString *> *)parameters
                 processorBlock:(AJRArgumentProcessorBlock)processorBlock
                           help:(NSString *)help
                        repeats:(BOOL)repeats
                       required:(BOOL)required {
    return [self registerArgument:[AJRCmndArg commandWithArgument:argument
                                                      parameters:parameters
                                                  processorBlock:processorBlock
                                                            help:help
                                                         repeats:repeats
                                                        required:required]];
}

- (AJRCmndArg *)registerArgument:(NSString *)argument
                      parameter:(nullable NSString *)parameter
                           type:(AJRArgumentType)type
                       property:(nullable NSString *)property
                           help:(NSString *)help
                        repeats:(BOOL)repeats
                       required:(BOOL)required {
    return [self registerArgument:[AJRCmndArg commandWithArgument:argument
                                                       parameter:parameter
                                                            type:type
                                                        property:property
                                                            help:help
                                                         repeats:repeats
                                                        required:required]];
}

- (AJRCmndArg *)registerArgument:(AJRCmndArg *)argument {
    if (!_commandArguments) {
        _commandArguments = [NSMutableArray array];
        _argumentIndex = [NSMutableDictionary dictionary];
    }
    [_commandArguments addObject:argument];
    [_argumentIndex setObject:argument forKey:[argument argument]];
    return argument;
}

- (void)willRun {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMainWillRunNotification object:self];
}

- (void)willTerminateWithExitCode:(int)exitCode {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMainWillTerminateNotification object:self userInfo:@{AJRMainTerminateCodeKey:@(exitCode)}];
}

- (void)didRun {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMainDidRunNotification object:(id)self];
}

- (void)willProcessArguments {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMainWillProcessArgumentsNotification object:self];
}

- (void)didProcessArguments {
    [[NSNotificationCenter defaultCenter] postNotificationName:AJRMainDidProcessArgumentsNotification object:self];
}

- (void)begin {
    @autoreleasepool {
        if (_autoprocessArguments) {
            [self processArguments];
        }
    }
    [self run];
}

- (void)run {
    [self willRun];
    if (_managesRunLoop) {
        [[NSRunLoop currentRunLoop] run];
    }
    [self didRun];
}

- (oneway void)terminateWithExitCode:(int)errorLevel {
    [self willTerminateWithExitCode:errorLevel];
    exit(errorLevel);
}

- (oneway void)terminate {
    [self terminateWithExitCode:0];
}

- (void)setApplicationName:(NSString *)newName {
    if (!AJREqual(_applicationName, newName)) {
        _applicationName = newName;
        [_processInformation setProcessName:newName];
    }
}

- (NSString *)hostName {
    return [_processInformation hostName];
}

- (NSString *)processName {
    return _applicationName;
}

- (void)setLogLevel:(AJRLogLevel)logLevel {
    AJRLogSetGlobalLogLevel(logLevel);
}

- (AJRLogLevel)logLevel {
    return AJRLogGetGlobalLogLevel();
}

- (void)windowDidResize {
}

- (BOOL)_processSignal:(int)signal {
    BOOL result;
    @autoreleasepool {
        
        result = [self processSignal:signal];
        
    }
    
    if (!result) {
        if (_assignalHandlers[signal]) {
            _assignalHandlers[signal](signal);
        } else {
            switch (signal) {
                case SIGWINCH:
                    [self windowDidResize];
                    break;
                case SIGINT:
                    AJRPrintf(@"\n");
                    [self terminateWithExitCode:signal];
                default:
                    [self emitMessage:@"Unhandled signal: %d\n", signal];
                    [self terminateWithExitCode:signal];
                    break;
            }
        }
    }
    
    return result;
}

- (BOOL)processSignal:(int)signal {
    return NO;
}

@end

