
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRFileFinderTests : XCTestCase

@end

@implementation AJRFileFinderTests

- (void)testDeveloperPath {
    NSString *path = [AJRFileFinder developerPath];
    XCTAssert(path != nil);
}

- (void)testSimpleHeaderSearch {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinderForHeaderFilesInSDK:AJRDeveloperSDKAll];
    
    NSArray<NSString *> *paths = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(paths.count > 0);

    fileFinder.allowDuplicates = NO;
    paths = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(paths.count == 1);
    
    fileFinder.caseSensitive = YES;
    paths = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(paths.count == 1);

    fileFinder.findFirstOnly = YES;
    paths = [fileFinder findFiles:@"curl.h" inSubpath:@"curl"];
    XCTAssert(paths.count == 1);
}

- (void)testLibrarySearching {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinderWithExtension:@"bundle"];
    
    // We have to add this manually, because in a unit test, the main bundle is actually to the xctest agent.
    [fileFinder addAllBundles];
    NSArray<NSString *> *paths = [fileFinder findFiles];
    BOOL found = NO;
    for (NSString *path in paths) {
        if ([path hasSuffix:@"Resources/AJRPlugInManagerTestBundle.bundle"]) {
            found = YES;
            break;
        }
    }
    XCTAssert(found);
    
    [fileFinder removeAllSearchPaths];
    paths = [fileFinder findFiles];
    XCTAssert(paths.count == 0);
    
    [fileFinder addBundle:[NSBundle bundleForClass:self.class]];
    paths = [fileFinder findFiles];
    XCTAssert(paths.count == 1);
    
    fileFinder.extension = @"BUNDLE";
    fileFinder.findFirstOnly = YES;
    paths = [fileFinder findFiles];
    XCTAssert(paths.count == 1);
    
    fileFinder.caseSensitive = YES;
    fileFinder.findFirstOnly = YES;
    paths = [fileFinder findFiles];
    XCTAssert(paths.count == 0);
    
    [fileFinder addSearchPaths:NSLibraryDirectory inDomains:NSUserDomainMask];
    fileFinder.sharedFolderSubpath = nil;
    fileFinder.extension = @"bundle";
    fileFinder.caseSensitive = YES;
    fileFinder.findFirstOnly = YES;
    paths = [fileFinder findFiles];
    XCTAssert(paths.count == 1);
}

- (void)testErrorHandling {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinder];
    
    [fileFinder addSearchPaths:@[@"/$(BAD)"]];
    
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(output, AJRLogLevelWarning);
    NSArray<NSString *> *paths = [fileFinder findFiles:@"test"];
    XCTAssert(paths.count == 0);
    
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    XCTAssert([[output ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: Unknown variable in path: BAD"]);
}

- (void)testOtherSearchPaths {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinder];
    
    fileFinder.searchHome = YES;
    
    NSArray<NSString *> *paths = [fileFinder findFiles:@".cshrc"];
    XCTAssert(paths.count == 1);
    
    [NSFileManager.defaultManager changeCurrentDirectoryPath:NSTemporaryDirectory()];
    NSString *temp = NSFileManager.defaultManager.temporaryFilename;
    XCTAssert([[NSData data] writeToFile:temp atomically:YES]);
    
    fileFinder.searchCurrentDirectory = YES;
    paths = [fileFinder findFiles:[temp lastPathComponent]];
    XCTAssert(paths.count == 1);
    
    [NSFileManager.defaultManager removeItemAtPath:temp error:NULL];
    
    paths = [fileFinder findFiles:[temp lastPathComponent]];
    XCTAssert(paths.count == 0);
    
    fileFinder.searchEnvironmentPath = YES;
    paths = [fileFinder findFiles:@"more"];
    XCTAssert([paths containsObject:@"/usr/bin/more"]);
}

- (void)testClassConveniences {
    // We test these actual searches in other test, so just make sure data passes through correctly.
    AJRFileFinder *finder = [AJRFileFinder fileFinderWithSubpath:@"Test" andExtension:@"ext"];
    XCTAssert([finder.subpath isEqualToString:@"Test"]);
    XCTAssert([finder.extension isEqualToString:@"ext"]);
    
    // For the next test, let's create a file we can find.
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponents:@[@"Library", NSProcessInfo.processInfo.processName]];
    NSString *subdirectory = [directory stringByAppendingPathComponent:@"Subdirectory"];
    NSString *path = [directory stringByAppendingPathComponent:@"test-to-find"];
    NSString *path2 = [subdirectory stringByAppendingPathComponent:@"test-to-find-2"];
    NSString *path3 = [subdirectory stringByAppendingPathComponent:@"test-to-find-3.csh"];
    NSString *path4 = [subdirectory stringByAppendingPathComponent:@"test-to-find-4.csh"];

    XCTAssert([NSFileManager.defaultManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions:@(0755)} error:NULL]);
    XCTAssert([NSFileManager.defaultManager createFileAtPath:path contents:[NSData data] attributes:@{NSFilePosixPermissions:@(0644)}]);
    XCTAssert([NSFileManager.defaultManager createDirectoryAtPath:subdirectory withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions:@(0755)} error:NULL]);
    XCTAssert([NSFileManager.defaultManager createFileAtPath:path2 contents:[NSData data] attributes:@{NSFilePosixPermissions:@(0644)}]);
    XCTAssert([NSFileManager.defaultManager createFileAtPath:path3 contents:[NSData data] attributes:@{NSFilePosixPermissions:@(0644)}]);
    XCTAssert([NSFileManager.defaultManager createFileAtPath:path4 contents:[NSData data] attributes:@{NSFilePosixPermissions:@(0644)}]);

    NSArray<NSString *> *paths = [AJRFileFinder findFiles:@"test-to-find"];
    XCTAssert(paths.count == 1 && [paths[0] isEqualToString:path]);
    paths = [AJRFileFinder findFiles:@"test-to-find-2"];
    XCTAssert(paths.count == 0);

    paths = [AJRFileFinder findFiles:@"test-to-find-2" inSubpath:@"Subdirectory"];
    XCTAssert(paths.count == 1 && [paths[0] isEqualToString:path2]);
    paths = [AJRFileFinder findFiles:@"test-to-find" inSubpath:@"Subdirectory"];
    XCTAssert(paths.count == 0);

    paths = [AJRFileFinder findFilesForSubpath:@"Subdirectory" andExtension:@"csh"];
    XCTAssert(paths.count == 2);
    XCTAssert([paths containsObject:path3]);
    XCTAssert([paths containsObject:path4]);

    [NSFileManager.defaultManager removeItemAtPath:directory error:NULL];
}

- (void)testSearchPaths {
    AJRFileFinder *finder = [AJRFileFinder fileFinder];
    
    [finder removeAllSearchPaths];
    XCTAssert(finder.searchPaths.count == 0);
    
    [finder addSearchPaths:NSLibraryDirectory inDomains:NSUserDomainMask];
    XCTAssert(finder.searchPaths.count == 1);
    [finder removeSearchPaths:NSLibraryDirectory inDomains:NSUserDomainMask];
    XCTAssert(finder.searchPaths.count == 0);
    
    [finder addSearchPaths:NSLibraryDirectory inDomains:NSAllDomainsMask];
    XCTAssert(finder.searchPaths.count > 0);
    [finder removeSearchPaths:finder.searchPaths];
    XCTAssert(finder.searchPaths.count == 0);
    
    [finder addSearchPaths:NSLibraryDirectory inDomains:NSAllDomainsMask];
    XCTAssert(finder.searchPaths.count > 0);
    for (NSString *path in finder.searchPaths) {
        [finder removeSearchPaths:@[path.stringByDeletingLastPathComponent]];
    }
    XCTAssert(finder.searchPaths.count == 0);
}

- (void)testEnvironmentPaths {
    AJRFileFinder *finder = [AJRFileFinder fileFinderForExecutablesInEnvironmentPath];
    NSArray<NSString *> *paths = [finder findFiles:@"more"];
    XCTAssert([paths containsObject:@"/usr/bin/more"]);
}

@end
