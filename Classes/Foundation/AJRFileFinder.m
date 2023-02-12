/*
 AJRFileFinder.m
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

#import "AJRFileFinder.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "NSMutableArray+Extensions.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"

static NSMutableArray<NSURL *> *_environmentPaths = nil;

@implementation AJRFileFinder {
    NSMutableOrderedSet<NSURL *> *_searchPaths;
}

+ (void)initialize {
    [[[NSProcessInfo processInfo] environment] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *object, BOOL *stop) {
        if ([key caseInsensitiveCompare:@"path"] == NSOrderedSame) {
            _environmentPaths = [NSMutableArray array];
            [[object componentsSeparatedByString:@":"] enumerateObjectsUsingBlock:^(NSString *path, NSUInteger index, BOOL *stop) {
                [_environmentPaths addObject:[NSURL fileURLWithPath:path]];
            }];
            *stop = YES;
        }
    }];
}

+ (id)fileFinder {
    return [[self alloc] init];
}

+ (id)fileFinderWithExtension:(NSString *)extension {
    return [[self alloc] initWithExtension:extension];
}

+ (id)fileFinderWithSubpath:(NSString *)path andExtension:(NSString *)extension {
    return [[self alloc] initWithSubpath:path andExtension:extension];
}

+ (id)fileFinderForHeaderFilesInSDK:(AJRDeveloperSDK)sdkMask {
    return [[self alloc] initForHeaderFilesInSDK:sdkMask];
}

+ (NSArray<NSURL *> *)findFiles:(NSString *)filename {
    return [[[self alloc] init] findFiles:filename];
}

+ (NSArray<NSURL *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path {
    return [[[self alloc] init] findFiles:filename inSubpath:path];
}

+ (NSArray<NSURL *> *)findFilesForSubpath:(NSString *)path andExtension:(NSString *)extension {
    return [[[self alloc] initWithSubpath:path andExtension:extension] findFiles];
}

+ (nullable NSURL *)findApplicationNamed:(NSString *)applicationName {
    return [[[[self alloc] initForApplications] findFiles:applicationName] firstObject];
}


+ (NSArray<NSURL *> *)findInEnvironmentPathExecutablesNamed:(NSString *)executableName {
    return [[[self alloc] initForExecutablesInEnvironmentPath] findFiles:executableName];
}

+ (id)fileFinderForExecutablesInEnvironmentPath {
    return [[self alloc] initForExecutablesInEnvironmentPath];
}

- (id)init {
    return [self initWithSubpath:nil andExtension:nil];
}

- (id)initWithExtension:(NSString *)extension {
    return [self initWithSubpath:nil andExtension:extension];
}

- (id)initWithSubpath:(NSString *)path andExtension:(NSString *)extension {
    if ((self = [super init])) {
        self.extension = extension;
        self.subpath = path;
        self.sharedFolderSubpath = NSProcessInfo.processInfo.processName;
        self.searchCurrentDirectory = NO;
        self.allowDuplicates = YES;
        self.searchHome = NO;
        self.caseSensitive = NO;
        self.searchEnvironmentPath = NO;
        self.sorted = NO;
        [self addSearchPaths:NSLibraryDirectory inDomains:NSAllDomainsMask];
        [self addSearchPaths:NSAllLibrariesDirectory inDomains:NSAllDomainsMask];
        [self addSearchPaths:NSApplicationSupportDirectory inDomains:NSAllDomainsMask];
        [self addSearchPaths:NSCachesDirectory inDomains:NSAllDomainsMask];
        [self addSearchPaths:@[NSBundle.mainBundle.builtInPlugInsURL]];
        [self addSearchPaths:@[NSBundle.mainBundle.resourceURL]];
    }
    
    return self;
}

- (id)initForApplications {
    if ((self = [super init])) {
        self.extension = @"app";
        self.subpath = nil;
        self.searchCurrentDirectory = NO;
        self.allowDuplicates = YES;
        self.searchHome = NO;
        self.caseSensitive = NO;
        self.searchEnvironmentPath = NO;
        self.sorted = NO;
        [self addSearchPaths:NSApplicationDirectory inDomains:NSAllDomainsMask];
        [self addSearchPaths:NSDeveloperApplicationDirectory inDomains:NSAllDomainsMask];
    }
    return self;
}

- (id)initForHeaderFilesInSDK:(AJRDeveloperSDK)sdkMask {
    if ((self = [self initWithSubpath:nil andExtension:nil])) {
        self.allowDuplicates = YES;
        [self addDeveloperSDKs:AJRDeveloperSDKAll];
        [self addSearchPaths:@[[NSURL fileURLWithPath:@"/usr/include"],
                               [NSURL fileURLWithPath:@"/usr/local/include"],
                               [NSURL fileURLWithPath:@"/opt/local/include"]]];
    }
    return self;
}

- (instancetype)initForExecutablesInEnvironmentPath {
    if ((self = [self initWithSubpath:nil andExtension:nil])) {
        [self removeAllSearchPaths];
        self.searchEnvironmentPath = YES;
    }
    return self;
}


#pragma mark - Global Properties

+ (NSURL *)developerPath {
#if defined(AJRFoundation_iOS)
    // iOS will never have a developer path (well, at least for now).
    return nil;
#else
    static NSString *developerPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSTask *task = [[NSTask alloc] init];
        NSPipe *pipe = [NSPipe pipe];
        task.launchPath = @"/usr/bin/xcode-select";
        task.standardOutput = pipe;
        task.arguments = @[@"-p"];
        [task launch];
        [task waitUntilExit];
        if (task.terminationStatus == 0) {
            NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
            developerPath = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        }
    });
    return [NSURL fileURLWithPath:developerPath];
#endif
}

#pragma mark - Utilities

- (NSString *)_variableInString:(NSString *)string at:(NSRangePointer)rangePtr {
    NSString *variable = nil;
    NSRange openRange = [string rangeOfString:@"$("];
    if (openRange.location != NSNotFound) {
        NSRange closeRange = [string rangeOfString:@")" options:0 range:(NSRange){NSMaxRange(openRange), string.length - NSMaxRange(openRange)}];
        if (closeRange.location != NSNotFound) {
            NSRange variableRange = (NSRange){openRange.location, NSMaxRange(closeRange) - openRange.location};
            variable = [string substringWithRange:(NSRange){NSMaxRange(openRange), closeRange.location - NSMaxRange(openRange)}];
            AJRSetOutParameter(rangePtr, variableRange);
        }
    }
    return variable;
}

- (NSURL *)_pathBySubstitutingVariablesInPath:(NSURL *)input {
    NSMutableString *string = [[input path] mutableCopy];

    NSString *variable;
    NSRange variableRange;
    while ((variable = [self _variableInString:string at:&variableRange]) != nil) {
        NSString *value = @"";
        if ([variable isEqualToString:@"SUBPATH"]) {
            value = _subpath ?: @"";
        } else if ([variable isEqualToString:@"SHARED_SUBPATH"]) {
            value = _sharedFolderSubpath ?: @"";
        } else {
            AJRLog(nil, AJRLogLevelWarning, @"Unknown variable in path: %@", variable);
        }
        [string replaceCharactersInRange:variableRange withString:value];
    }
    return [[NSURL fileURLWithPath:string] URLByStandardizingPath];
}

- (BOOL)_insert:(NSURL *)filenameIn into:(NSMutableArray<NSURL *> *)array {
    BOOL inserted = NO;
    if (filenameIn != nil) {
        NSURL *filename = [filenameIn URLByStandardizingPath];

        if (!_allowDuplicates) {
            NSString *name = [filename lastPathComponent];
            
            for (NSString *existingName in array) {
                if ([name compare:[existingName lastPathComponent] options:(_caseSensitive ? 0 : NSCaseInsensitiveSearch)] == NSOrderedSame) {
                    return inserted;
                }
            }
        }
        
        if (![array containsObject:filename]) {
            [array addObject:filename];
            inserted = YES;
        }
    }
    return inserted;
}

- (NSURL *)pathForFilename:(NSString *)file inPath:(NSURL *)path {
    NSURL *fullPath = [[self _pathBySubstitutingVariablesInPath:path] URLByAppendingPathComponent:file];

    if (_extension != NULL) {
        fullPath = [fullPath URLByAppendingPathExtension:_extension];
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath.path] ? fullPath : nil;
}

- (BOOL)_filesInto:(NSMutableArray *)files withExtension:(NSString *)ext inPath:(NSURL *)pathIn {
    BOOL inserted = NO;
    NSURL *path = [self _pathBySubstitutingVariablesInPath:pathIn];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:path includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    NSURL *name;
    NSString *currentExtension;
    
    // now search for files with the given extension.
    while ((name = [enumerator nextObject])) {
        currentExtension = [name pathExtension];
        if ([currentExtension length]) {
            if (_caseSensitive) {
                if ([currentExtension isEqualToString:ext]) {
                    if ([self _insert:name into:files]) {
                        inserted = YES;
                        if (_findFirstOnly) {
                            break;
                        }
                    }
                }
            } else {
                if ([currentExtension caseInsensitiveCompare:ext] == NSOrderedSame) {
                    if ([self _insert:name into:files]) {
                        inserted = YES;
                        if (_findFirstOnly) {
                            break;
                        }
                    }
                }
            }
        }
    }
    
    return inserted;
}

- (void)_searchCallingBlock:(void (^)(NSURL *path, BOOL *stop))block {
    BOOL stop = NO;
    
    if (_searchHome) {
        block(AJRHomeDirectoryURL(), &stop);
    }
    
    if (!stop) {
        for (NSURL *path in _searchPaths) {
            block(path, &stop);
            if (stop) {
                break;
            }
        }
    }
    
    if (!stop && _searchCurrentDirectory) {
        block([NSURL fileURLWithPath:NSFileManager.defaultManager.currentDirectoryPath], &stop);
    }
    
    if (!stop && _searchEnvironmentPath) {
        for (NSURL *path in _environmentPaths) {
            block(path, &stop);
        }
    }
}

- (NSArray<NSURL *> *)findFiles:(NSString *)filename {
    NSMutableArray<NSURL *> *foundPaths = [NSMutableArray array];
    
    [self _searchCallingBlock:^(NSURL *path, BOOL *stop) {
        *stop = [self _insert:[self pathForFilename:filename inPath:path] into:foundPaths] && self->_findFirstOnly;
    }];
    
    return foundPaths;
}

- (NSArray<NSURL *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path {
    NSString *savedSubpath = self.subpath;
    NSArray<NSURL *> *result;
    
    self.subpath = path;
    result = [self findFiles:filename];
    self.subpath = savedSubpath;
    
    return result;
}

- (NSArray<NSURL *> *)findFiles {
    NSMutableArray<NSURL *> *files = [NSMutableArray array];
    
    [self _searchCallingBlock:^(NSURL *path, BOOL *stop) {
        *stop = [self _filesInto:files withExtension:self->_extension inPath:path] && self->_findFirstOnly;
    }];
    
    return files;
}

#pragma mark - Search Criteria

- (NSArray<NSURL *> *)searchPaths {
    return _searchPaths.array;
}

- (void)_modifySearchPathsUsingBlock:(void (^)(NSMutableOrderedSet *searchPaths))block {
    if (_searchPaths == nil) {
        _searchPaths = [NSMutableOrderedSet orderedSet];
    }
    block(_searchPaths);
}

- (void)removeAllSearchPaths {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        [searchPaths removeAllObjects];
    }];
}

- (NSArray<NSURL *> *)pathsForPathDirectory:(NSSearchPathDirectory)directory mask:(NSSearchPathDomainMask) mask {
    NSMutableArray<NSURL *> *paths = [NSMutableArray array];
    BOOL includeSharedLibrarySubpath = (directory == NSApplicationSupportDirectory
                                        || directory == NSLibraryDirectory
                                        || directory == NSAllLibrariesDirectory
                                        || directory == NSCachesDirectory);
    
    for (NSString *path in NSSearchPathForDirectoriesInDomains(directory, mask, YES)) {
        NSString *workPath = path;
        if (includeSharedLibrarySubpath) {
            workPath = [workPath stringByAppendingPathComponent:@"$(SHARED_SUBPATH)"];
        }
        workPath = [workPath stringByAppendingPathComponent:@"$(SUBPATH)"];
        [paths addObject:[NSURL fileURLWithPath:workPath]];
    }
    
    return paths;
}

- (void)addSearchPaths:(NSSearchPathDirectory)paths inDomains:(NSSearchPathDomainMask)mask {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        [searchPaths addObjectsFromArray:[self pathsForPathDirectory:paths mask:mask]];
    }];
}

- (void)removeSearchPaths:(NSSearchPathDirectory)paths inDomains:(NSSearchPathDomainMask)mask {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        [searchPaths removeObjectsInArray:[self pathsForPathDirectory:paths mask:mask]];
    }];
}

- (void)addSearchPaths:(NSArray<NSURL *> *)paths {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        for (NSURL *path in paths) {
            [searchPaths addObject:[path URLByAppendingPathComponent:@"$(SUBPATH)"]];
        }
    }];
}

- (void)removeSearchPaths:(NSArray<NSURL *> *)paths {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        for (NSURL *path in paths) {
            NSURL *work = path;
            if (![work.lastPathComponent hasSuffix:@"$(SUBPATH)"]) {
                work = [work URLByAppendingPathComponent:@"$(SUBPATH)"];
            }
            [searchPaths removeObject:work];
        }
    }];
}

- (void)addBundle:(NSBundle *)bundle {
    NSMutableArray<NSURL *> *paths = [NSMutableArray array];
    
    [paths addObject:bundle.builtInPlugInsURL];
    [paths addObject:bundle.resourceURL];
    [paths addObject:bundle.sharedFrameworksURL];
    [paths addObject:bundle.privateFrameworksURL];
    
    [self addSearchPaths:paths];
}

- (void)addAllBundles {
    NSMutableSet<NSBundle *> *bundles = [NSMutableSet set];
    
    [bundles addObjectsFromArray:NSBundle.allBundles];
    [bundles addObjectsFromArray:NSBundle.allFrameworks];
    
    for (NSBundle *bundle in bundles) {
        [self addBundle:bundle];
    }
}

- (void)_addPathsForDeveloperSDKNamed:(NSString *)name to:(NSMutableArray<NSURL *> *)paths {
    NSURL *developerPath = AJRFileFinder.developerPath;
    if (developerPath != nil) {
        NSString *platform = AJRFormat(@"%@.platform", name);
        NSString *sdk = AJRFormat(@"%@.sdk", name);
        [paths addObject:[developerPath URLByAppendingPathComponents:@[@"Platforms", platform, @"Developer", @"SDKs", sdk, @"usr", @"include"]]];
    }
}

- (void)addDeveloperSDKs:(AJRDeveloperSDK)mask {
    NSMutableArray<NSURL *> *paths = [NSMutableArray array];
    if (mask & AJRDeveloperSDKMacOSX) {
        [self _addPathsForDeveloperSDKNamed:@"MacOSX" to:paths];
    }
    if (mask & AJRDeveloperSDKiPhoneOS) {
        [self _addPathsForDeveloperSDKNamed:@"iPhoneOS" to:paths];
    }
    if (mask & AJRDeveloperSDKiPhoneSimulator) {
        [self _addPathsForDeveloperSDKNamed:@"iPhoneSimulator" to:paths];
    }
    if (mask & AJRDeveloperSDKiPadOS) {
        [self _addPathsForDeveloperSDKNamed:@"iPadOS" to:paths];
    }
    if (mask & AJRDeveloperSDKiPadSimulator) {
        [self _addPathsForDeveloperSDKNamed:@"iPadSimulator" to:paths];
    }
    if (mask & AJRDeveloperSDKAppleTVOS) {
        [self _addPathsForDeveloperSDKNamed:@"AppleTVOS" to:paths];
    }
    if (mask & AJRDeveloperSDKAppleTVSimulator) {
        [self _addPathsForDeveloperSDKNamed:@"AppleTVSimulator" to:paths];
    }
    if (mask & AJRDeveloperSDKWatchOS) {
        [self _addPathsForDeveloperSDKNamed:@"WatchOS" to:paths];
    }
    if (mask & AJRDeveloperSDKWatchSimulator) {
        [self _addPathsForDeveloperSDKNamed:@"WatchSimulator" to:paths];
    }
    [self addSearchPaths:paths];
}

@end
