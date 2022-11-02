/*
 AJRTranslator.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

#import "AJRTranslator.h"

#import "AJRFormat.h"
#import "AJRLogging.h"

#import <objc/runtime.h>

NSString * const AJRSharedStringsTableName = @"AJRSharedStrings";
static NSString * const AJRNoTranslationString = @"*BAD*";
NSString *const AJRTanslatorDidChangeLanguageNotification = @"AJRTanslatorDidChangeLanguageNotification";

static NSMutableDictionary *_translators = nil;
static id <NSLocking> _stringTablesLock = nil;
static NSMutableDictionary *_stringTables = nil;


@interface AJRTranslator ()

+ (NSDictionary *)stringTableForName:(NSString *)name bundle:(NSBundle *)bundle;
+ (void)flushStringTables;

- (void)_startLanguageChange;
- (void)_endLanguageChange;

@end


@implementation AJRTranslator {
    NSMutableArray<NSString *> *_stringTableNames;
    NSMutableSet<NSBundle *> *_bundles;
    NSMutableDictionary *_cache;
}


+ (void)initialize {
    if (_translators == nil) {
        NSTimer *timer;
        
        _translators = [[NSMutableDictionary alloc] init];
        _stringTablesLock = [[NSRecursiveLock alloc] init];
        _stringTables = [[NSMutableDictionary alloc] init];
        
        timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(_checkLanguages:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

+ (void)_checkLanguages:(id)sender {
    static NSArray *previous = nil;
    static NSArray *current = nil;
    
    //AJRLogDebug(@"ping");
    
    current = [[NSUserDefaults standardUserDefaults] arrayForKey:@"AppleLanguages"];
    if (previous == nil) {
        previous = current;
    } else if (![current isEqualToArray:previous]) {
        previous = current;
        
        @synchronized (self) {
            // Now tell all the various translators that we're changing language. We start by sending _startLanguageChange which basically allows the translators to send willChangeValueForKey: for each of their translation keys. At this point, even though the language is changed, because all the language values are cached in string tables, they'll continue to return the old values, so it is safe to send teh willChangeValueForKey: messages.
            for (NSString *key in _translators) {
                AJRTranslator    *translator = [_translators objectForKey:key];
                [translator _startLanguageChange];
            }
            // Now we can flush our string tables.
            [self flushStringTables];
            // Now tell the translators we've flushed our caches. This basically means that new calls to them will return the new languages values. In otherwords, they can now send didChangeValueForKey:
            for (NSString *key in _translators) {
                AJRTranslator    *translator = [_translators objectForKey:key];
                [translator _endLanguageChange];
            }
            // Finally, since not everything can be bound via KVO, broadcast a message that the languages have changed and let any manual translation happen.
            [[NSNotificationCenter defaultCenter] postNotificationName:AJRTanslatorDidChangeLanguageNotification object:self];
        }
        
        AJRLogDebug(@"change");
    }
}

+ (AJRTranslator *)translatorForObject:(id)object {
    return [self translatorForClass:[object class]];
}

+ (AJRTranslator *)translatorForClass:(Class)class; {
    NSString *key = NSStringFromClass(class);
    AJRTranslator *translator = [_translators objectForKey:key];
    
    // Avoid synchronizing, if we can.
    if (translator == nil) {
        // We'll now attempt synchronization.
        @synchronized (self) {
            // Double check that the translator is still nil. It may have been set by another thread,
            // since our first attempt to access isn't locked.
            translator = [_translators objectForKey:key];
            if (translator == nil) {
                // Yup, it's still nil, so create the translator.
                translator = [class createTranslator];
                [_translators setObject:translator forKey:key];
            }
        }
    }
    
    return translator;
}

- (id)initForClass:(Class)class {
    return [self initForClass:class stringTableNames:[class translatorTableNames]];
}

- (instancetype)initForClass:(Class)class stringTableNames:(NSArray<NSString *> *)stringTableNames {
    if ((self = [super init])) {
        _stringTableNames = [stringTableNames mutableCopy];
        _bundles = [NSMutableSet set];
        [_bundles addObject:[NSBundle bundleForClass:class]];
        // I'm not 100% sure about this, but right now, this makes menus translate correctly.
        [_bundles addObject:[NSBundle mainBundle]];
        _cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma String Tables

+ (NSString *)keyForStringTableForName:(NSString *)name bundle:(NSBundle *)bundle {
    return [NSString stringWithFormat:@"%@:%@", [bundle bundlePath], name];
}

// This is bad, because it's horribly incomplete. There should be a way to get this information from the system somewhere.
+ (NSString *)_alternateLanguageNameForLanguageName:(NSString *)name {
    if ([name isEqualToString:@"en"]) return @"English";
    if ([name isEqualToString:@"es"]) return @"Spanish";
    if ([name isEqualToString:@"fr"]) return @"French";
    if ([name isEqualToString:@"English"]) return @"en";
    if ([name isEqualToString:@"Spanish"]) return @"sp";
    if ([name isEqualToString:@"French"]) return @"fr";
    
    NSRange range = [name rangeOfString:@"-"];
    if (range.location != NSNotFound) {
        return [name substringToIndex:range.location];
    }
    
    return nil;
}

+ (NSDictionary *)stringTableForName:(NSString *)name bundle:(NSBundle *)bundle {
    NSString *key = [self keyForStringTableForName:name bundle:bundle];
    NSDictionary *table = nil;
    
    [_stringTablesLock lock];
    @try {
        table = [_stringTables objectForKey:key];
        
        if (table == nil) {
            NSString *path = nil;
            NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
            
            for (NSString *language in languages) {
                NSString *alt;
                
                path = [bundle pathForResource:name ofType:@"strings" inDirectory:nil forLocalization:language];
                if (path) break;
                alt = [self _alternateLanguageNameForLanguageName:language];
                if (alt) {
                    path = [bundle pathForResource:name ofType:@"strings" inDirectory:nil forLocalization:alt];
                    if (path) break;
                }
            }
            if (path == nil) {
                path = [bundle pathForResource:name ofType:@"strings" inDirectory:nil forLocalization:@"Base"];
            }
            if (path) {
                table = [[NSDictionary alloc] initWithContentsOfFile:path];
                if (table) {
                    [_stringTables setObject:table forKey:key];
                } else {
                    [_stringTables setObject:[NSNull null] forKey:key];
                }
            } else {
                [_stringTables setObject:[NSNull null] forKey:key];
            }
        } else if (table == (id)[NSNull null]) {
            table = nil;
        }
    } @finally {
        [_stringTablesLock unlock];
    }
    
    return table;
}

+ (void)flushStringTables {
    [_stringTablesLock lock];
    @try {
        [_stringTables removeAllObjects];
    } @finally {
        [_stringTablesLock unlock];
    }
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)name bundle:(NSBundle *)bundle {
    NSString *string = [[[self class] stringTableForName:name bundle:bundle] objectForKey:key];
    return string == nil ? value : string;
}

#pragma NSKeyValueCoding

- (id)valueForKey:(NSString *)key {
    return [self valueForKey:key defaultValue:key];
}

- (id)valueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSString *value;
    
    value = [_cache objectForKey:key];
    if (value) return value;
    
    // First, try to get the translation from a string file named after the object's class.
    for (NSString *stringTableName in _stringTableNames) {
        for (NSBundle *bundle in _bundles) {
            value = [self localizedStringForKey:key value:AJRNoTranslationString table:stringTableName bundle:bundle];
            if (value != nil && ![value isEqualToString:AJRNoTranslationString]) {
                break;
            }
        }
        if (value != nil && ![value isEqualToString:AJRNoTranslationString]) {
            break;
        }
    }
    if (value == nil || [value isEqualToString:AJRNoTranslationString]) {
        for (NSString *stringTableName in _stringTableNames) {
            // If that fails, try the main bundle, since the main bundle might try to cover translations for a framework.
            value = [self localizedStringForKey:key value:AJRNoTranslationString table:stringTableName bundle:[NSBundle mainBundle]];
            if (value != nil && ![value isEqualToString:AJRNoTranslationString]) {
                break;
            }
        }
    }
    if (value == nil || [value isEqualToString:AJRNoTranslationString]) {
        // If that fails, try a string file named after the bundle.
        for (NSBundle *bundle in _bundles) {
            NSString *name = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
            value = [self localizedStringForKey:key value:AJRNoTranslationString table:name bundle:bundle];
            if (value && ![value isEqualToString:AJRNoTranslationString]) {
                break;
            }
        }
    }
    // If that fails, we'll try shared strings
    if (value == nil || [value isEqualToString:AJRNoTranslationString]) {
        for (NSBundle *bundle in _bundles) {
            value = [self localizedStringForKey:key value:AJRNoTranslationString table:AJRSharedStringsTableName bundle:bundle];
            if (value && ![value isEqualToString:AJRNoTranslationString]) {
                break;
            }
        }
    }
    // If we're still nil, then just return default value.
    if (value == nil || [value isEqualToString:AJRNoTranslationString]) {
        value = [NSString stringWithFormat:@"»%@«", defaultValue];
    }
    
    [_cache setObject:value forKey:key];
    
    return value;
}

- (void)_startLanguageChange {
    NSArray *keys = [[_cache allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (NSString *key in keys) {
        [self willChangeValueForKey:key];
    }
}

- (void)_endLanguageChange {
    NSArray *keys = [[_cache allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [_cache removeAllObjects];
    for (NSString *key in keys) {
        [self didChangeValueForKey:key];
    }
}

- (void)addAlternateBundle:(NSBundle *)bundle {
    [_bundles addObject:bundle];
}

- (void)removeAlternateBundle:(NSBundle *)bundle {
    [_bundles removeObject:bundle];
}

- (void)addStringTableName:(NSString *)name {
    if ([_stringTableNames indexOfObject:name] == NSNotFound) {
        [_stringTableNames addObject:name];
    }
}

- (void)removeStringTableName:(NSString *)name {
    [_stringTableNames removeObject:name];
}

@end

@implementation NSObject (AJRTranslator)

+ (AJRTranslator *)createTranslator {
    return [[AJRTranslator alloc] initForClass:self stringTableNames:[self translatorTableNames]];
}

+ (NSArray<NSString *> *)translatorTableNames {
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    Class class = self;
    
    while (class != Nil) {
        NSString *possibleStringTableName = NSStringFromClass(class);
        // A small hack to deal with classes written in Swift.
        NSRange range = [possibleStringTableName rangeOfString:@"."];
        if (range.location != NSNotFound) {
            possibleStringTableName = [possibleStringTableName substringFromIndex:range.location + range.length];
        }
        [names addObject:possibleStringTableName];
        class = [class superclass];
    }
    
    return names;
}

+ (AJRTranslator *)translator {
    return [AJRTranslator translatorForClass:self];
}

- (AJRTranslator *)translator {
    return [self ajr_translator];
}

- (AJRTranslator *)ajr_translator {
    return [AJRTranslator translatorForObject:self];
}

- (NSString *)translationKey {
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
    return objc_getAssociatedObject(self, @"__translation_key__");
#else
    return nil;
#endif
}

- (void)setTranslationKey:(NSString *)key {
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
    objc_setAssociatedObject(self, @"__translation_key__", key, OBJC_ASSOCIATION_RETAIN);
#endif
}

@end
