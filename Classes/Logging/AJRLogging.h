/*
 AJRLogging.h
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

#import <AJRFoundation/AJRFunctions.h>

#import <syslog.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int8_t, AJRLogLevel) {
    AJRLogLevelDefault = -1,
    AJRLogLevelEmergency = LOG_EMERG,
    AJRLogLevelAlert = LOG_ALERT,
    AJRLogLevelCritical = LOG_CRIT,
    AJRLogLevelError = LOG_ERR,
    AJRLogLevelWarning = LOG_WARNING,
    AJRLogLevelNotice = LOG_NOTICE,
    AJRLogLevelInfo = LOG_INFO,
    AJRLogLevelDebug = LOG_DEBUG
};

typedef NSString *AJRLoggingDomain NS_EXTENSIBLE_STRING_ENUM;

/*! Sets the output stream for the specified log level. If stream is nil, this reset the specified log level back to the default stream. If level is AJRLogLevelDefault and stream is nil, the output stream is reset back to stderr. Finally, if the stream is not open, the functions attempts to open the stream.
 @param stream The output stream to write the log info. If nil, reset to use the default stream or stderr.
 @param level The level who's stream is set.
 */
extern void AJRLogSetOutputStream(NSOutputStream * _Nullable stream, AJRLogLevel level);
/*! Returns the output stream for level, or the default stream if there's no specific stream for the level.
 @param level The level for the desired output stream.
 @return The appropriate output stream. If the system is logging via syslog and no output stream has been explicitly set, the function will return nil.
 */
extern NSOutputStream * _Nullable AJRLogGetOutputStream(AJRLogLevel level);

/*!
 Sets whether or not the default log output is syslog() or stdout / stderr. Note that the default stream can be changed by calling AJRSetLogginStream(stream, AJRLogLevelDefault).
 */
extern void AJRLogSetUsesSyslog(BOOL flag);
/*!
 Returns if logging, by default, is sent to syslog or to stdout / stderr. The default is YES.
 */
extern BOOL AJRLogGetUsesSyslog(void);

extern void AJRLog_fv(AJRLoggingDomain _Nullable domain, AJRLogLevel level, NSString *format, va_list ap);
extern void AJRLog(AJRLoggingDomain _Nullable domain, AJRLogLevel level, NSString *format, ...);
extern void AJRSimpleLog(AJRLoggingDomain _Nullable domain, AJRLogLevel level, NSString *message);

extern void AJRLogSetGlobalLogLevel(AJRLogLevel level);
extern AJRLogLevel AJRLogGetGlobalLogLevel(void);
extern void AJRLogSetLogLevel(AJRLogLevel level, AJRLoggingDomain domain);
extern AJRLogLevel AJRLogGetLogLevel(AJRLoggingDomain _Nullable domain);

extern BOOL AJRLogShouldOutputForDomain(AJRLoggingDomain _Nullable domain, AJRLogLevel level);

extern NSInteger AJRLogGetDefaultCount(void);
extern NSInteger AJRLogGetEmergencyCount(void);
extern NSInteger AJRLogGetAlertCount(void);
extern NSInteger AJRLogGetCriticalCount(void);
extern NSInteger AJRLogGetErrorCount(void);
extern NSInteger AJRLogGetWarningCount(void);
extern NSInteger AJRLogGetNoticeCount(void);
extern NSInteger AJRLogGetInfoCount(void);
extern NSInteger AJRLogGetDebugCount(void);
extern void AJRLogResetCounts(void);

extern AJRLogLevel AJRLogLevelFromString(NSString *string);
extern NSString * _Nullable AJRStringFromLogLevel(AJRLogLevel level);

/*! Don't call this function. It's here to be used as a springboard for the logging macros. */
extern void _AJRLog_impl_fv(volatile const void *owner, const char *functionOrMethod, AJRLogLevel level, NSString *format, va_list ap);
/*! Don't call this function. It's here to be used as a springboard for the logging macros. */
extern void _AJRLog_impl_f(volatile const void *owner, const char *functionOrMethod, AJRLogLevel level, NSString *format, ...);

#define AJRLogEmergency(...) _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelEmergency, __VA_ARGS__)
#define AJRLogAlert(...)     _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelAlert, __VA_ARGS__)
#define AJRLogCritical(...)  _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelCritical, __VA_ARGS__)
#define AJRLogError(...)     _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelError, __VA_ARGS__)
#define AJRLogWarning(...)   _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelWarning, __VA_ARGS__)
#define AJRLogNotice(...)    _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelNotice, __VA_ARGS__)
#define AJRLogInfo(...)      _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelInfo, __VA_ARGS__)
#define AJRLogDebug(...)     _AJRLog_impl_f(&self, __PRETTY_FUNCTION__, AJRLogLevelDebug, __VA_ARGS__);

NS_ASSUME_NONNULL_END
