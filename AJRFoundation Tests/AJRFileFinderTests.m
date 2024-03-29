/*
 AJRFileFinderTests.m
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

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRFileFinderTests : XCTestCase

@end

@implementation AJRFileFinderTests

- (void)testDeveloperPath {
    NSURL *path = [AJRFileFinder developerPath];
    XCTAssert(path != nil);
}

- (void)testSimpleHeaderSearch {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinderForHeaderFilesInSDK:AJRDeveloperSDKAll];
    
    NSArray<NSURL *> *urls = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(urls.count > 0);

    fileFinder.allowDuplicates = NO;
    urls = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(urls.count == 1);
    
    fileFinder.caseSensitive = YES;
    urls = [fileFinder findFiles:@"stdlib.h"];
    XCTAssert(urls.count == 1);

    fileFinder.findFirstOnly = YES;
    urls = [fileFinder findFiles:@"curl.h" inSubpath:@"curl"];
    XCTAssert(urls.count == 1);
}

- (void)testLibrarySearching {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinderWithExtension:@"bundle"];
    
    // We have to add this manually, because in a unit test, the main bundle is actually to the xctest agent.
    [fileFinder addAllBundles];
    NSArray<NSURL *> *urls = [fileFinder findFiles];
    BOOL found = NO;
    for (NSURL *url in urls) {
        if ([url.path hasSuffix:@"Resources/AJRPlugInManagerTestBundle.bundle"]) {
            found = YES;
            break;
        }
    }
    XCTAssert(found);
    
    [fileFinder removeAllSearchPaths];
    urls = [fileFinder findFiles];
    XCTAssert(urls.count == 0);
    
    [fileFinder addBundle:[NSBundle bundleForClass:self.class]];
    urls = [fileFinder findFiles];
    XCTAssert(urls.count == 1);
    
    fileFinder.extension = @"BUNDLE";
    fileFinder.findFirstOnly = YES;
    urls = [fileFinder findFiles];
    XCTAssert(urls.count == 1);
    
    fileFinder.caseSensitive = YES;
    fileFinder.findFirstOnly = YES;
    urls = [fileFinder findFiles];
    XCTAssert(urls.count == 0);
    
    [fileFinder addSearchPaths:NSLibraryDirectory inDomains:NSUserDomainMask];
    fileFinder.sharedFolderSubpath = nil;
    fileFinder.extension = @"bundle";
    fileFinder.caseSensitive = YES;
    fileFinder.findFirstOnly = YES;
    urls = [fileFinder findFiles];
    XCTAssert(urls.count == 1);
}

- (void)testErrorHandling {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinder];
    
    [fileFinder addSearchPaths:@[[NSURL fileURLWithPath:@"/$(BAD)"]]];
    
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(output, AJRLogLevelWarning);
    NSArray<NSURL *> *urls = [fileFinder findFiles:@"test"];
    XCTAssert(urls.count == 0);
    
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
    XCTAssert([[output ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] containsString:@"<WARNING>: Unknown variable in path: BAD"]);
}

- (void)testOtherSearchPaths {
    AJRFileFinder *fileFinder = [AJRFileFinder fileFinder];
    
    fileFinder.searchHome = YES;
    
    NSArray<NSURL *> *urls = [fileFinder findFiles:@".cshrc"];
    XCTAssert(urls.count == 1);
    
    [NSFileManager.defaultManager changeCurrentDirectoryPath:NSTemporaryDirectory()];
    NSString *temp = NSFileManager.defaultManager.temporaryFilename;
    XCTAssert([[NSData data] writeToFile:temp atomically:YES]);
    
    fileFinder.searchCurrentDirectory = YES;
    urls = [fileFinder findFiles:[temp lastPathComponent]];
    XCTAssert(urls.count == 1);
    
    [NSFileManager.defaultManager removeItemAtPath:temp error:NULL];
    
    urls = [fileFinder findFiles:[temp lastPathComponent]];
    XCTAssert(urls.count == 0);
    
    fileFinder.searchEnvironmentPath = YES;
    urls = [fileFinder findFiles:@"more"];
    XCTAssert([urls containsObject:[NSURL fileURLWithPath:@"/usr/bin/more"]]);
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

    NSArray<NSURL *> *paths = [AJRFileFinder findFiles:@"test-to-find"];
    XCTAssert(paths.count == 1 && [paths[0] isEqualToURL:[NSURL fileURLWithPath:path]]);
    paths = [AJRFileFinder findFiles:@"test-to-find-2"];
    XCTAssert(paths.count == 0);

    paths = [AJRFileFinder findFiles:@"test-to-find-2" inSubpath:@"Subdirectory"];
    XCTAssert(paths.count == 1 && [paths[0] isEqualToURL:[NSURL fileURLWithPath:path2]]);
    paths = [AJRFileFinder findFiles:@"test-to-find" inSubpath:@"Subdirectory"];
    XCTAssert(paths.count == 0);

    paths = [AJRFileFinder findFilesForSubpath:@"Subdirectory" andExtension:@"csh"];
    XCTAssert(paths.count == 2);
    XCTAssert([paths containsObject:[NSURL fileURLWithPath:path3]]);
    XCTAssert([paths containsObject:[NSURL fileURLWithPath:path4]]);

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
    for (NSURL *path in finder.searchPaths) {
        [finder removeSearchPaths:@[[path URLByDeletingLastPathComponent]]];
    }
    XCTAssert(finder.searchPaths.count == 0);
}

- (void)testEnvironmentPaths {
    AJRFileFinder *finder = [AJRFileFinder fileFinderForExecutablesInEnvironmentPath];
    NSArray<NSURL *> *paths = [finder findFiles:@"more"];
    XCTAssert([paths containsObject:[NSURL fileURLWithPath:@"/usr/bin/more"]]);

    paths = [AJRFileFinder findInEnvironmentPathExecutablesNamed:@"less"];
    XCTAssert([paths containsObject:[NSURL fileURLWithPath:@"/usr/bin/less"]]);
}

- (void)testFindApplications {
    NSURL *url = [AJRFileFinder findApplicationNamed:@"TextEdit"];
    XCTAssert(url != nil);
}

@end
