/*
 AJRLogging.m
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

#import "AJRLogging.h"

#import "AJRFileOutputStream.h"
#import "AJRFormat.h"

static NSString * const AJRDefaultLoggingDomain = @"__DEFAULT__";

static id <NSLocking> _logLock = nil;
static AJRLogLevel _globalLogLevel = AJRLogLevelInfo;
static NSMutableDictionary *_logLevelByDomain = nil;

static BOOL _logIsOpen = NO;
static BOOL _logUsingSyslog = YES;

static NSInteger _defaultCount = 0;
static NSInteger _emergencyCount = 0;
static NSInteger _alertCount = 0;
static NSInteger _criticalCount = 0;
static NSInteger _errorCount = 0;
static NSInteger _warningCount = 0;
static NSInteger _noticeCount = 0;
static NSInteger _infoCount = 0;
static NSInteger _debugCount = 0;

@interface AJRLogger : NSObject
@end

@implementation AJRLogger

+ (void)load {
    _logLevelByDomain = [[NSMutableDictionary alloc] init];
    _logLock = [[NSRecursiveLock alloc] init];
}

@end

static NSMutableDictionary<NSNumber *, NSOutputStream *> * AJRGetLoggingLevelToStreams(void) {
    static NSMutableDictionary<NSNumber *, NSOutputStream *> *_loggingStreams = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _loggingStreams = [NSMutableDictionary dictionary];
        [_loggingStreams setObject:[AJRFileOutputStream outputStreamWithFile:stderr closeOnDeallocate:NO] forKey:@(AJRLogLevelDefault)];
    });
    return _loggingStreams;
}

void AJRLogSetOutputStream(NSOutputStream *stream, AJRLogLevel level) {
    if (stream == nil) {
        if (level == AJRLogLevelDefault) {
            [AJRGetLoggingLevelToStreams() setObject:[AJRFileOutputStream outputStreamWithFile:stderr closeOnDeallocate:NO] forKey:@(level)];
        } else {
            [AJRGetLoggingLevelToStreams() removeObjectForKey:@(level)];
        }
    } else {
        [AJRGetLoggingLevelToStreams() setObject:stream forKey:@(level)];
        if ([stream streamStatus] != NSStreamStatusOpen) {
            [stream open];
        }
    }
}

NSOutputStream *AJRLogGetOutputStream(AJRLogLevel level) {
    NSOutputStream *possible = [AJRGetLoggingLevelToStreams() objectForKey:@(level)];
    if (possible == nil && !_logUsingSyslog) {
        possible = AJRLogGetOutputStream(AJRLogLevelDefault);
    }
    return possible;
}

BOOL AJRLogGetUsesSyslog(void) {
    return _logUsingSyslog;
}

void AJRLogSetUsesSyslog(BOOL flag) {
    _logUsingSyslog = flag;
}

BOOL AJRLogShouldOutputForDomain(NSString *domain, AJRLogLevel level) {
    AJRLogLevel currentLevel = AJRLogGetLogLevel(domain);
    if (currentLevel == AJRLogLevelDefault) {
        return level <= _globalLogLevel;
    }
    return level <= currentLevel;
}

static void AJRLog_fvp(NSString *domain, AJRLogLevel level, NSString *format, va_list ap) {
    [_logLock lock];
    @try {
        NSString *formattedString;
        
        if (!_logIsOpen) {
            setlogmask(LOG_UPTO(_globalLogLevel));
            openlog([[[NSProcessInfo processInfo] processName] UTF8String], LOG_NDELAY, LOG_USER);
            _logIsOpen = YES;
        }
        
        formattedString = AJRFormatv(format, ap);
        switch (level) {
            case AJRLogLevelDefault:    _defaultCount++; break;
            case AJRLogLevelEmergency:  _emergencyCount++; break;
            case AJRLogLevelAlert:      _alertCount++; break;
            case AJRLogLevelCritical:   _criticalCount++; break;
            case AJRLogLevelError:      _errorCount++; break;
            case AJRLogLevelWarning:    _warningCount++; break;
            case AJRLogLevelNotice:     _noticeCount++; break;
            case AJRLogLevelInfo:       _infoCount++; break;
            case AJRLogLevelDebug:      _debugCount++; break;
        }
        
        
        if (AJRLogShouldOutputForDomain(domain, level)) {
            // When building for debug, just log to the console.
            BOOL needsNewline = ![formattedString hasSuffix:@"\n"];
            NSString *logString;
            if (domain != nil) {
                logString = [[NSString alloc] initWithFormat:@"%@ <%@>: %@%@", domain, AJRStringFromLogLevel(level), formattedString, needsNewline ? @"\n" : @""];
            } else {
                logString = [[NSString alloc] initWithFormat:@"<%@>: %@%@", AJRStringFromLogLevel(level), formattedString, needsNewline ? @"\n" : @""];
            }
            NSData *data = [logString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSOutputStream *stream = AJRLogGetOutputStream(level);
            // If there's an output stream, log to it, otherwise, just log to syslog.
            if (stream) {
                [AJRLogGetOutputStream(level) write:[data bytes] maxLength:[data length]];
            } else {
                if (domain == nil) {
                    syslog(level, "<%s> %s", [AJRStringFromLogLevel(level) UTF8String], [formattedString UTF8String]);
                } else {
                    syslog(level, "%s <%s> %s", [domain UTF8String], [AJRStringFromLogLevel(level) UTF8String], [formattedString UTF8String]);
                }
            }
        }
    } @finally {
        [_logLock unlock];
    }
}

void AJRLog_fv(NSString *domain, AJRLogLevel level, NSString *format, va_list ap) {
    if (AJRLogShouldOutputForDomain(domain, level)) {
        AJRLog_fvp(domain, level, format, ap);
    }
}

void AJRLog(NSString *domain, AJRLogLevel level, NSString *format, ...) {
    if (AJRLogShouldOutputForDomain(domain, level)) {
        va_list ap;
        va_start(ap, format);
        AJRLog_fvp(domain, level, format, ap);
        va_end(ap);
    }
}

void AJRSimpleLog(NSString * _Nullable domain, AJRLogLevel level, NSString *message) {
    AJRLog(domain, level, @"%@", message);
}


void _AJRLog_impl_fv(volatile const void *owner, const char *functionOrMethod, AJRLogLevel level, NSString *format, va_list ap) {
    NSString *domain = nil;
    
    if (owner == &self) {
        domain = [NSString stringWithCString:functionOrMethod encoding:NSUTF8StringEncoding];
    } else {
        id object = (owner != &self) ? *(__strong id *)owner : nil;
        if (object) {
            domain = NSStringFromClass([object class]);
        }
    }
    AJRLog_fv(domain, level, format, ap);
}

void _AJRLog_impl_f(volatile const void *owner, const char *functionOrMethod, AJRLogLevel level, NSString *format, ...) {
    va_list     ap;
    va_start(ap, format);
    _AJRLog_impl_fv(owner, functionOrMethod, level, format, ap);
    va_end(ap);
}

void AJRLogSetGlobalLogLevel(AJRLogLevel level) {
    _globalLogLevel = level;
    setlogmask(LOG_UPTO(_globalLogLevel));
}

AJRLogLevel AJRLogGetGlobalLogLevel(void) {
    return _globalLogLevel;
}

void AJRLogSetLogLevel(AJRLogLevel level, NSString *domain) {
    if (level == AJRLogLevelDefault) {
        [_logLevelByDomain removeObjectForKey:domain];
    } else {
        [_logLevelByDomain setObject:[NSNumber numberWithInteger:level] forKey:domain];
    }
}

AJRLogLevel AJRLogGetLogLevel(NSString *domain) {
    NSNumber *level = [_logLevelByDomain objectForKey:domain ?: AJRDefaultLoggingDomain];
    if (level == nil) {
        NSString *possibleLevel = [[[NSProcessInfo processInfo] environment] objectForKey:domain ?: AJRDefaultLoggingDomain];
        level = possibleLevel ? @(AJRLogLevelFromString(possibleLevel)) : @(AJRLogLevelDefault);
        [_logLevelByDomain setObject:level forKey:domain ?: AJRDefaultLoggingDomain];
    }
    return [level integerValue];
}

NSInteger AJRLogGetDefaultCount(void) {
    return _defaultCount;
}

NSInteger AJRLogGetEmergencyCount(void) {
    return _emergencyCount;
}

NSInteger AJRLogGetAlertCount(void) {
    return _alertCount;
}

NSInteger AJRLogGetCriticalCount(void) {
    return _criticalCount;
}

NSInteger AJRLogGetErrorCount(void) {
    return _errorCount;
}

NSInteger AJRLogGetWarningCount(void) {
    return _warningCount;
}

NSInteger AJRLogGetNoticeCount(void) {
    return _noticeCount;
}

NSInteger AJRLogGetInfoCount(void) {
    return _infoCount;
}

NSInteger AJRLogGetDebugCount(void) {
    return _debugCount;
}

void AJRLogResetCounts(void) {
    _defaultCount = 0;
    _emergencyCount = 0;
    _alertCount = 0;
    _criticalCount = 0;
    _errorCount = 0;
    _warningCount = 0;
    _noticeCount = 0;
    _infoCount = 0;
    _debugCount = 0;
}

// NOTE: Not declared static, so that the unit test can access this.
NSDictionary<NSNumber *, NSString *> *AJRGetLogLevelStrings(void) {
    static NSDictionary<NSNumber *, NSString *> *logLevelStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logLevelStrings = @{
                            @(AJRLogLevelDefault):@"DEFAULT",
                            @(AJRLogLevelEmergency):@"EMERGENCY",
                            @(AJRLogLevelAlert):@"ALERT",
                            @(AJRLogLevelCritical):@"CRITICAL",
                            @(AJRLogLevelError):@"ERROR",
                            @(AJRLogLevelWarning):@"WARNING",
                            @(AJRLogLevelNotice):@"NOTICE",
                            @(AJRLogLevelInfo):@"INFO",
                            @(AJRLogLevelDebug):@"DEBUG",
                            };
    });
    return logLevelStrings;
}

AJRLogLevel AJRLogLevelFromString(NSString *string) {
    NSNumber *possible = [[AJRGetLogLevelStrings() allKeysForObject:[string uppercaseString]] firstObject];
    return possible ? [possible integerValue] : AJRLogLevelDefault;
}

NSString *AJRStringFromLogLevel(AJRLogLevel level) {
    return [AJRGetLogLevelStrings() objectForKey:@(level)];
}
