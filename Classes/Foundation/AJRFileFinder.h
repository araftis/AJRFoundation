/*
AJRFileFinder.h
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

/*!
 @header AJRFileFinder.h
 @discussion Defines the AJRFileFinder
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(uint32_t, AJRDeveloperSDK) {
    AJRDeveloperSDKMacOSX           = 0x001,
    AJRDeveloperSDKiPadOS           = 0x002,
    AJRDeveloperSDKiPadSimulator    = 0x004,
    AJRDeveloperSDKiPhoneOS         = 0x008,
    AJRDeveloperSDKiPhoneSimulator  = 0x010,
    AJRDeveloperSDKAppleTVOS        = 0x020,
    AJRDeveloperSDKAppleTVSimulator = 0x040,
    AJRDeveloperSDKWatchOS          = 0x080,
    AJRDeveloperSDKWatchSimulator   = 0x100,
    AJRDeveloperSDKAll              = 0x1FF,
};

/*!
 @class AJRFileFinder
 
 @abstract Search various standard file paths to location files and resources needed by a tool or application.
 
 @discussion This class allows you to search a set of standard directories, looking for a file, or a set of files. This is useful if you need to find a scattered list of files, or perhaps you need to find a particular configuration file.

 To find the files, the <CODE>AJRFileFinder</CODE> uses Apple's standard search order, by default. This order is to search Home, network, local, and finally sysmte. The class will search, also in order, the "Library", "Application Support", "Caches", and NSBundle.mainBundle resources. You can also easily add search of the user's home directory, the current directory, or the environment's PATH.
 
 Note that when some paths are search, the application automatically adds the <code>sharedFolderSubpath</code> to the path. This is done when the path is located in a "shared" space, for example, the library. For this reason, but default, rather than searching say "~/Library", AJRFileFinder would search "~/Library/<NSProcessInfo.processInfo.processName>". If you really don't want to search to include the process's name, you may set <code>sharedFolderSubpath</code> to <code>nil</code>.

 Using the class is fairly easy. In the easiest form, you can you <CODE>fileFinderForSubpath:andExtension:</CODE>. This allows you to search the default  directories for files in a given subpath with the given extension. A subpath is a path appended to the appropiate library path before the actual search is made. Here's an example that will search the library paths in a subdirectory called "Converters" looking for files with the extension ".bcvt":
 <PRE>
        files = [[AJRFileFinder filesFinderForSubpath:&#64;"Converters" andExtension:&#64;"bcvt"]];
 </PRE>
 This will return an NSArray of full path names of all files it found. This call, by default, will also not include duplicates.
 
 You can also search for header files by SDK. Note that the headers are always found in the current developer tools installation, as denoted by "xcode-select -p".  Header searches, by default, also include "/usr/include", "/usr/local/include", and "/opt/local/include".
 
 If you need more control over where and what files are search, you can create a finder with the more standard alloc and init calls. You can then customize the search parameters before executing the search.
 */

@interface AJRFileFinder : NSObject

#pragma mark - Creating instances

/*!
 @seealso - init
 @discussion Create a new <CODE>AJRFileFinder</CODE>  with no subpath, no extension, where the application locations will be searched..
 @result Returns <CODE>self</CODE>.
 */
+ (instancetype)fileFinder;

+ (id)fileFinderWithExtension:(NSString *)extension;

/*!
 @seealso initForSubpath:andExtension:

 @discussion Creates a new <CODE>AJRFileFinder</CODE> with subpath <CODE>path</CODE> and extension <CODE>anExtension</CODE>. The Library paths will be searched.

 @result Returns <CODE>self</CODE>.
 */
+ (instancetype)fileFinderWithSubpath:(NSString *)path andExtension:(NSString *)anExtension;

/*!
 @seealso - initForHeaderFiles:

 @discussion Creates a new <CODE>AJRFileFinder</CODE> designed to search the standard include paths.

 @result Returns <CODE>self</CODE>.
 */
+ (instancetype)fileFinderForHeaderFilesInSDK:(AJRDeveloperSDK)sdkMask;

/*!
 Returns an AJRFileFinder set up to search the user's PATH.
 
 @return A file finder configured to search the user's PATH environment variable.
 */
+ (instancetype)fileFinderForExecutablesInEnvironmentPath;

/*!
 @seealso - initForSubpath:andExtension:
 
 @discussion Messages <CODE>initForSubpath:andExtension:</CODE> with <CODE>path</CODE> and <CODE>anExtension</CODE> equal to <CODE>nil</CODE>.
 
 @result Returns <CODE>self</CODE>
 */
- (instancetype)init;

- (instancetype)initWithExtension:(NSString *)extension;

/*!
 @discussion Initializes a newly created instance of AJRFileFinder. The subpath is set equal to <CODE>path</CODE> and the extension is set to <CODE>anExtension</CODE>. Either of these values may be <CODE>nil</CODE>. The instance is set to only search the Library paths. You'll need to configure the instance with additional messages to change the search criteria.
 @result Returns <CODE>self</CODE>.
 */
- (instancetype)initWithSubpath:(nullable NSString *)path andExtension:(nullable NSString *)anExtension;

/*!
 @discussion Initializes a newly created instance of <CODE>AJRFileFinder</CODE>. The class is set up to search the standard include paths used by the C compiler.
 */
- (instancetype)initForHeaderFilesInSDK:(AJRDeveloperSDK)sdkMask;

/*!
 Creates a file finder configured to find executables in the user's environemnt path.
 
 @returns A newly created file finder.
 */
- (instancetype)initForExecutablesInEnvironmentPath;

#pragma mark - Global Properties

@property (nonatomic,class,readonly,nullable) NSString *developerPath;

#pragma mark - Searching
 
/*!
 @seealso findFiles:

 @discussion Searches the standard Library paths for <CODE> filename</CODE>.

 @result If it finds the file, it returns the full path to the file. Otherwise, it returns <CODE>nil</CODE>.
 */
+ (NSArray<NSString *> *)findFiles:(NSString *)filename;

/*!
 @seealso +findFile

 @discussion Searches the standard Library paths for <CODE>filename</CODE> in subpath <CODE>path</CODE>.

 @result If it finds the file, it returns the full path to the file, otherwise, it returns <CODE>nil</CODE>.
 */
+ (NSArray<NSString *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path;

/*!
 @seealso -findFilesForSubpath:andExtension:

 @discussion Searches the Library paths with appended subpath <CODE>path</CODE> for files with <CODE>anExtension</CODE>.

 @result Returns a alphabetically sorted array of pathnames.
 */
+ (NSArray<NSString *> *)findFilesForSubpath:(nullable NSString *)path andExtension:(NSString *)anExtension;

/*!
 Searches the user's PATH set in their environment for the executable of the provided name. This may return multiple values if the executable exists in multiple locations. This only searches the current directory if the search path includes '.'. You can change that by setting searchCurrentDirectory to YES.
 
 @returns An array of paths to executables named executableName.
 */
+ (NSArray<NSString *> *)findInEnvironmentPathExecutablesNamed:(NSString *)executableName;

/*!
 @discussion Checks for the existance of <CODE>file</CODE> in <CODE>path</CODE> an returns the full path name for the file if it exists.

 @result The full path name to the <CODE>file</CODE> if it exists in <CODE>path</CODE> or <CODE>nil</CODE>.
 */
- (NSString *)pathForFilename:(NSString *)file inPath:(NSString *)path;

/*!
 @seealso -findFiles, +findFiles:

 @discussion Searches via it's current search criteria for <CODE> filename</CODE>. If it finds the file, it returns the full path to the first occurance. If it fails to find the file, it returns <CODE>nil</CODE>. If you need to find all instances of a file, you should use <CODE>findFiles</CODE> with uniqueing turned off.
 */
- (NSArray<NSString *> *)findFiles:(NSString *)filename;

/*!
 @discussion Searches the list of directories for <CODE>file</CODE> located with <CODE>path</CODE>.

 @result The fully qualified path if found, or <CODE>nil</CODE> if no file can be found.
 */
- (NSArray<NSString *> *)findFiles:(NSString *)filename inSubpath:(NSString *)path;

/*!
 @seealso -findFiles:, +findFiles

 @discussion Returns an array of files as defined by the current search criteria. The order and uniqueness of the array is also controlled by user settings. By default, the array filenames will be unique and sorted.
 */
- (NSArray<NSString *> *)findFiles;

#pragma mark - Setting search criteria

@property (nonatomic,readonly) NSArray<NSString *> *searchPaths;

- (void)removeAllSearchPaths;
- (void)addSearchPaths:(NSSearchPathDirectory)paths inDomains:(NSSearchPathDomainMask)mask;
- (void)removeSearchPaths:(NSSearchPathDirectory)paths inDomains:(NSSearchPathDomainMask)mask;
- (void)addSearchPaths:(NSArray<NSString *> *)paths;
- (void)removeSearchPaths:(NSArray<NSString *> *)paths;

- (void)addBundle:(NSBundle *)bundle;
- (void)addAllBundles;

- (void)addDeveloperSDKs:(AJRDeveloperSDK)mask;

/*!
 @discussion Set the filename extension to <CODE>value</CODE>. This value is used when searching for lists of files. For example, setting the extension to "master would search for all files ending in ".master".
 */
@property (nullable,nonatomic,strong) NSString *extension;

/*!
 @discussion This is the subpath to use when the path is part of a "shared" structure, like a libary. For example, you wouldn't normally want to put something into ~/Library directly, so by default, sharedFolderSubpath will be initialized the the process name, which would make the library folder to search ~/Library/<process_name>.
 */
@property (nullable,nonatomic,strong) NSString *sharedFolderSubpath;

/*!
 @discussion Sets the the subpath to search when looking in directories. The subpath extends the path used when searching. For example, if you create a subdirectory off a library folder to holder your application's specific files, you can set the subpath to this directory name. Then, when searching, the finder will look in the subdirectory rather than just the base directory.
 
 This property is used in conjunction with sharedFolderSubpath, where the final folder to search would be, for example, ~Library/<sharedFolderSubpath>/<subpath>.
 
 The value may be nil, in which case no subpath is used.
 */
@property (nullable,nonatomic,strong) NSString *subpath;

/*!
 @discussion Returns whether or not duplicate filenames will be returned. Duplicates are defined as two files that exist in two different directories, but which share the same name.
 */
@property (nonatomic,assign) BOOL allowDuplicates;

/*!
 @discussion Returns whether or not filenames should be considered case sensitive when comparing against things like duplicates.
 */
@property (nonatomic,assign,getter=isCaseSensitive) BOOL caseSensitive;

/*!
 @discussion Return whether or not the returned arrays of filenames are sorted.
 @result YES if the returned files are sorted.
 */
@property (nonatomic,assign,getter=isSorted) BOOL sorted;

/*!
 @discussion Returns YES if the current user's home directory is searched.
 */
@property (nonatomic,assign) BOOL searchHome;
@property (nonatomic,assign) BOOL searchCurrentDirectory;
@property (nonatomic,assign) BOOL searchEnvironmentPath;
@property (nonatomic,assign) BOOL findFirstOnly;

@end

NS_ASSUME_NONNULL_END
