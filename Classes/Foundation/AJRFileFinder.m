
#import "AJRFileFinder.h"

#import "AJRFormat.h"
#import "AJRFunctions.h"
#import "AJRLogging.h"
#import "NSMutableArray+Extensions.h"
#import "NSString+Extensions.h"

static NSMutableArray<NSString *> *_environmentPaths = nil;

@implementation AJRFileFinder {
    NSMutableOrderedSet<NSString *> *_searchPaths;
}

+ (void)initialize {
    [[[NSProcessInfo processInfo] environment] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *object, BOOL *stop) {
        if ([key caseInsensitiveCompare:@"path"] == NSOrderedSame) {
            _environmentPaths = [[object componentsSeparatedByString:@":"] mutableCopy];
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

+ (NSArray<NSString *> *)findFiles:(NSString *)filename {
    return [[[self alloc] init] findFiles:filename];
}

+ (NSArray<NSString *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path {
    return [[[self alloc] init] findFiles:filename inSubpath:path];
}

+ (NSArray<NSString *> *)findFilesForSubpath:(NSString *)path andExtension:(NSString *)extension {
    return [[[self alloc] initWithSubpath:path andExtension:extension] findFiles];
}

+ (NSArray<NSString *> *)findInEnvironmentPathExecutablesNamed:(NSString *)executableName {
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
        [self addSearchPaths:@[NSBundle.mainBundle.builtInPlugInsPath]];
        [self addSearchPaths:@[NSBundle.mainBundle.resourcePath]];
    }
    
    return self;
}

- (id)initForHeaderFilesInSDK:(AJRDeveloperSDK)sdkMask {
    if ((self = [self initWithSubpath:nil andExtension:nil])) {
        self.allowDuplicates = YES;
        [self addDeveloperSDKs:AJRDeveloperSDKAll];
        [self addSearchPaths:@[@"/usr/include", @"/usr/local/include", @"/opt/local/include"]];
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

+ (NSString *)developerPath {
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
    return developerPath;
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

- (NSString *)_pathBySubstitutingVariablesInPath:(NSString *)input {
    NSMutableString *string = [input mutableCopy];

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
    return [string stringByStandardizingPath];
}

- (BOOL)_insert:(NSString *)filenameIn into:(NSMutableArray<NSString *> *)array {
    BOOL inserted = NO;
    if (filenameIn != nil) {
        NSString *filename = [filenameIn stringByStandardizingPath];

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

- (NSString *)pathForFilename:(NSString *)file inPath:(NSString *)path {
    NSString *fullPath = [[self _pathBySubstitutingVariablesInPath:path] stringByAppendingPathComponent:file];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath] ? fullPath : nil;
}

- (BOOL)_filesInto:(NSMutableArray *)files withExtension:(NSString *)ext inPath:(NSString *)pathIn {
    BOOL inserted = NO;
    NSString *path = [self _pathBySubstitutingVariablesInPath:pathIn];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *name;
    NSString *currentExtension;
    
    // now search for files with the given extension.
    while ((name = [enumerator nextObject])) {
        [enumerator skipDescendents];
        currentExtension = [name pathExtension];
        if ([currentExtension length]) {
            if (_caseSensitive) {
                if ([currentExtension isEqualToString:ext]) {
                    if ([self _insert:[path stringByAppendingPathComponent:name] into:files]) {
                        inserted = YES;
                        if (_findFirstOnly) {
                            break;
                        }
                    }
                }
            } else {
                if ([currentExtension caseInsensitiveCompare:ext] == NSOrderedSame) {
                    if ([self _insert:[path stringByAppendingPathComponent:name] into:files]) {
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

- (void)_searchCallingBlock:(void (^)(NSString *path, BOOL *stop))block {
    BOOL stop = NO;
    
    if (_searchHome) {
        block(NSHomeDirectory(), &stop);
    }
    
    if (!stop) {
        for (NSString *path in _searchPaths) {
            block(path, &stop);
            if (stop) {
                break;
            }
        }
    }
    
    if (!stop && _searchCurrentDirectory) {
        block(NSFileManager.defaultManager.currentDirectoryPath, &stop);
    }
    
    if (!stop && _searchEnvironmentPath) {
        for (NSString *path in _environmentPaths) {
            block(path, &stop);
        }
    }
}

- (NSArray<NSString *> *)findFiles:(NSString *)filename {
    NSMutableArray<NSString *> *foundPaths = [NSMutableArray array];
    
    [self _searchCallingBlock:^(NSString *path, BOOL *stop) {
        *stop = [self _insert:[self pathForFilename:filename inPath:path] into:foundPaths] && self->_findFirstOnly;
    }];
    
    return foundPaths;
}

- (NSArray<NSString *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path {
    NSString *savedSubpath = self.subpath;
    NSArray<NSString *> *result;
    
    self.subpath = path;
    result = [self findFiles:filename];
    self.subpath = savedSubpath;
    
    return result;
}

- (NSArray<NSString *> *)findFiles {
    NSMutableArray<NSString *> *files = [NSMutableArray array];
    
    [self _searchCallingBlock:^(NSString *path, BOOL *stop) {
        *stop = [self _filesInto:files withExtension:self->_extension inPath:path] && self->_findFirstOnly;
    }];
    
    return files;
}

#pragma mark - Search Criteria

- (NSArray<NSString *> *)searchPaths {
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

- (NSArray<NSString *> *)pathsForPathDirectory:(NSSearchPathDirectory)directory mask:(NSSearchPathDomainMask) mask {
    NSMutableArray<NSString *> *paths = [NSMutableArray array];
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
        [paths addObject:workPath];
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

- (void)addSearchPaths:(NSArray<NSString *> *)paths {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        for (NSString *path in paths) {
            [searchPaths addObject:[path stringByAppendingPathComponent:@"$(SUBPATH)"]];
        }
    }];
}

- (void)removeSearchPaths:(NSArray<NSString *> *)paths {
    [self _modifySearchPathsUsingBlock:^(NSMutableOrderedSet *searchPaths) {
        for (NSString *path in paths) {
            NSString *work = path;
            if (![work hasSuffix:@"$(SUBPATH)"]) {
                work = [work stringByAppendingPathComponent:@"$(SUBPATH)"];
            }
            [searchPaths removeObject:work];
        }
    }];
}

- (void)addBundle:(NSBundle *)bundle {
    NSMutableArray<NSString *> *paths = [NSMutableArray array];
    
    [paths addObject:bundle.builtInPlugInsPath];
    [paths addObject:bundle.resourcePath];
    [paths addObject:bundle.sharedFrameworksPath];
    [paths addObject:bundle.privateFrameworksPath];
    
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

- (void)_addPathsForDeveloperSDKNamed:(NSString *)name to:(NSMutableArray<NSString *> *)paths {
    NSString *developerPath = AJRFileFinder.developerPath;
    if (developerPath != nil) {
        NSString *platform = AJRFormat(@"%@.platform", name);
        NSString *sdk = AJRFormat(@"%@.sdk", name);
        [paths addObject:[developerPath stringByAppendingPathComponents:@[@"Platforms", platform, @"Developer", @"SDKs", sdk, @"usr", @"include"]]];
    }
}

- (void)addDeveloperSDKs:(AJRDeveloperSDK)mask {
    NSMutableArray<NSString *> *paths = [NSMutableArray array];
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
