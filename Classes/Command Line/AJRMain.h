/*
 AJRMain.h
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

#import <Foundation/Foundation.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/AJRLogging.h>
#import <AJRFoundation/AJRServerProtocols.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRMainWillRunNotification;
extern NSString * const AJRMainDidRunNotification;
extern NSString * const AJRMainWillTerminateNotification;
extern NSString * const AJRMainTerminateCodeKey;
extern NSString * const AJRMainWillProcessArgumentsNotification;
extern NSString * const AJRMainDidProcessArgumentsNotification;

extern int AJRToolMain(NSString *className, int argc, const char * _Nonnull argv[_Nonnull]);

typedef NS_ENUM(NSInteger, AJRArgumentType) {
    AJRArgumentTypeVoid,
    AJRArgumentTypeBoolean,
    AJRArgumentTypeInteger,
    AJRArgumentTypeLong,
    AJRArgumentTypeLongLong,
    AJRArgumentTypeFloat,
    AJRArgumentTypeDouble,
    AJRArgumentTypeCharacter,
    AJRArgumentTypeString,
};

/*! Returns the number of arguments consumed, or -1 if an error occurred processing the argument. */
typedef NSInteger (^AJRArgumentProcessorBlock)(id target, NSArray<NSString *> *arguments);

/*!
 * @class AJRCmndArg
 *
 * @discussion AJRCmndArg is used by AJRMain to hold all valid command line arguments that could
 * be passed on the command line. For most programs, these can automatically be used to
 * parse to command line for user parameters. If, for some reason, you need to do special
 * processing of the command line arguments, you can turn off the automatic feature.
 *
 * To create arguments for parsing, your application should call AJRMain's
 * registerArgument:parameter:type:selector:description:repeats: method repeatly for
 * each argument the user can place on the command line. Generally, these will be placed
 * within AJRMain's (or subclass') init method. Then, once the init method has returned,
 * the processArugments method will be called to determine and set all valid arguments.
 * if an invalid argument is called, the usage method will be called.
 *
 * By default, the usage message will print all valid arguments, a description of what they
 * should be and how they should be used, and then exits. You will have to override the
 * usage method in order to prevent the program exiting via a call to exit(1) if you do not
 * want the usage message to be fatal.
 */
@interface AJRCmndArg : NSObject

+ (instancetype)commandWithArgument:(NSString *)argument
                         parameters:(nullable NSArray<NSString *> *)parameters
                     processorBlock:(AJRArgumentProcessorBlock)processorBlock
                               help:(NSString *)help
                            repeats:(BOOL)repeats
                           required:(BOOL)required;

+ (instancetype)commandWithArgument:(NSString *)argument
                          parameter:(nullable NSString *)parameter
                               type:(AJRArgumentType)type
                           property:(nullable NSString *)property
                               help:(NSString *)help
                            repeats:(BOOL)repeats
                           required:(BOOL)required;

@property (nonatomic,strong) NSString *argument;
@property (nullable,nonatomic,strong) NSArray<NSString *> *parameters;
@property (nonatomic,strong) NSString *help;
@property (nonatomic,strong) NSString *property;
@property (nonatomic,strong) AJRArgumentProcessorBlock processorBlock;
@property (nonatomic,assign) BOOL used;
@property (nonatomic,assign) BOOL repeats;
@property (nonatomic,assign,getter=isRequired) BOOL required;

- (BOOL)isSingleArgument;

- (BOOL)isMatchFor:(NSString *)compare;

- (NSInteger)processWithTarget:(id)target arguments:(NSArray<NSString *> *)arguments;

@end

/*!
 * @class AJRMain
 *
 * @discussion AJRMain is an Objective C wrapper around the basic C main() routine which must be
 * present in all C programs. It is designed to make writting Objective-C programs that
 * work via the command line significantly easier. You will need to use Foundation Kit to
 * make use of AJRMain, as it tries to be as fully Foundation Kit compliant as is currently
 * possible.
 *
 * AJRMain will take care of most the things you need to worry about when writing a normal
 * C program, including command line arguments, argument parsing, messages and error
 * logging, as well as signal handling. It can also manage creating the main function on the
 * fly for you if you don't need to do anything special.
 *
 * Using AJRMain is fairly simple. You mostly just need to subclass the AJRMain object
 * and implement at least one method, run. This method will be called once everything has
 * been set up and is ready to run. Because C programs do not support event driven program
 * in any AppKit sense, all your actions must take place from within this method. This
 * method does not explicitly need to return, but if it does, the dealloc method will be called.
 * You could also end the program by calling the terminateWithExitCode: method, which will called C's
 * exit() function. This method depends on the C runtime system to clean up, which may
 * or may not meet your needs.
 *
 * Additionally, you can overload the init method which allows you to supply additional
 * initialization for your application. You init method should make sure to call [super init]
 * before it does it's own initialization. Note that init is called from within the initArgs:count:
 * method, which you should never overload, as it calls init for you. Generally speaking,
 * all you'll need to call from within init is the register... method to register the command line
 * arguments used by your program. Also, if you do not want to AJRMain to automatically
 * parse you arguments, you can also call setAutoprocessArguments: here.
 *
 * Finally, for you convenience for using NXStream's, AJRMain attachs stdin, stdout, and
 * stderr to AJRStrIn, AJRStdOut, and AJRStdErr, all NXStream's usable with the
 * standard NeXT streams library. Additionally, the functions AJRPrintf and AJRFPrintf
 * are defined and are equivalent to printf and fprintf. They are designed to work with
 * NXSteams and the Foundation Kit. NeXT's routines should be called for other I/O
 * processing.
 */
@interface AJRMain : NSObject <AJRMainRemoteProtocol>

#pragma mark - Help

- (void)usage;

#pragma mark - Creation

- (id)init;

#pragma mark - Arguments

- (void)processArguments;
- (AJRCmndArg *)registerArgument:(NSString *)argument
                     parameters:(nullable NSArray<NSString *> *)parameters
                 processorBlock:(AJRArgumentProcessorBlock)processorBlock
                           help:(NSString *)help
                        repeats:(BOOL)repeats
                       required:(BOOL)required;
- (AJRCmndArg *)registerArgument:(NSString *)argument
                      parameter:(nullable NSString *)parameter
                           type:(AJRArgumentType)type
                       property:(nullable NSString *)property
                           help:(NSString *)help
                        repeats:(BOOL)repeats
                       required:(BOOL)required;

#pragma mark - Notification Points

- (void)willRun;
- (void)willTerminateWithExitCode:(int)exitCode;
- (void)didRun;
- (void)willProcessArguments;
- (void)didProcessArguments;

#pragma mark - Running

/*! Processes the arguments, if autoprocessArguments is true, and then calls run. */
- (void)begin;
/*! If managesRunLoop is true, this runs the run loop. Subclasses should override this method to do their work, calling super at the end of their code. */
- (void)run;

- (oneway void)terminateWithExitCode:(int)errorLevel;
- (oneway void)terminate;

#pragma mark - Properties

@property (nonatomic,strong) NSString *applicationName;
@property (nonatomic,strong) NSString *applicationPath;
@property (nonatomic,readonly) NSString *userName;
@property (nonatomic,readonly) NSString *userHomeDirectory;

@property (nonatomic,readonly) NSArray<NSString *> *arguments;
@property (nonatomic,readonly) NSArray<AJRCmndArg *> *commandArguments;

@property (nonatomic,readonly) NSProcessInfo *processInformation;
@property (nonatomic,readonly) NSDate *startTime;
@property (nonatomic,assign) AJRLogLevel logLevel;
@property (nonatomic,assign) BOOL autoprocessArguments;
@property (nonatomic,assign) BOOL timeStamp;
@property (nonatomic,assign) BOOL managesRunLoop;

#pragma mark - Signal Handling

- (BOOL)processSignal:(int)signal;
- (void)windowDidResize;

@end

/*
 * Global like NXApp that let's the program always access the main application class.
 */
extern AJRMain * _Nullable ajrMain;

NS_ASSUME_NONNULL_END
