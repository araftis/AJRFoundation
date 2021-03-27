
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRMemoryHandle : NSFileHandle

+ (instancetype)memoryHandleForReadingData:(NSData *)data;
+ (instancetype)memoryHandleForReadingDataNoCopy:(NSData *)data;
+ (instancetype)memoryHandleForUpdatingData:(NSMutableData *)data error:(out NSError * _Nullable * _Nullable)error;
+ (instancetype)memoryHandleForWriting;
+ (instancetype)memoryHandleWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error;
+ (instancetype)memoryHandleWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error;

/*!
 Create a memory handle suitable for writing. The mutable data written to is created and can be accessed via the data or mutableData properties.
 
 @returns A newly created memory handle.
 */
- (instancetype)init;
/*!
 Creates a memory handling with the provided data suitable for reading. The provided data object is copied on creation. You will not be able to write to memory handle, even if you provide a mutable data object.
 
 @param data The data to be read. The data is copied.
 
 @return A newly created memory handle suitable for reading.
 */
- (instancetype)initWithData:(NSData *)data;
/*!
 Much like initWithData:, but the provided data object is not copied. Because the data is not copied, if you provide a mutable data object, the returned memory handle will be writable, but the initial position of the handle will be 0.
 
 @param data The data to read. If data is mutable, the handle can also be used for writing.
 
 @return A newly created memory handle suitable to reading, and possible writing, if the provided data object is mutable.
 */
- (instancetype)initWithDataNoCopy:(NSData *)data;
/*!
 Creates a memory handle suitable for reading and writing. The input must be mutable, and errors will be thrown if you provide a immutable data object. The initial position of the handle will be 0.
 
 @param data A mutable data object to write to.
 
 @returns A newly created memory handle suitable to reading and writing.
 */
- (instancetype)initWithMutableData:(NSMutableData *)data error:(out NSError * _Nullable * _Nullable)error;
/*!
 Creates a memory handle suitable for writing. It will also seek to the end of the data if seekToEnd is YES. This is useful when you want to update the mutable data. data must be mutable, or errors will be thrown when attempting to try and write to the handle.
 
 @param data The data to read to / write from.
 @param seekToEnd If YES, the position of the handle is set to data.length.
 
 @returns A newly creating memory handle suitable to reading and writing.
 */
- (instancetype)initWithMutableData:(NSMutableData *)data seekToEnd:(BOOL)seekToEnd error:(out NSError * _Nullable * _Nullable)error;
/*!
 Creates a memory handle by first reading the entire contents of path into a data object and then calling initWithData:. As such, the return handle cannot be used for writing.
 
 @param path The path to read.
 @param options NSDataReadingOptions that will be passed into NSData's initWithPath:options:error: method.
 @param error A pointer to an NSError that will be initialized if the path cannot be read.
 
 @returns A newly created memory handle suitable to reading the contents of path from memory. Nil is returns if the path cannot be read.
 */
- (instancetype)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error;
/*!
 Creates a memory handle by reading the contents of the url into an NSData and then calling initWithData:. As such, the returned handle is only suitable for reading.
 
 @param url The url to fetch into memory.
 @param options NSDataReadingOptions that will be passed into -[NSData initWithContentsOfURL:options:error:].
 @param error A pointer to an NSError that will be initialized if that data cannot be read from url.
 
 @returns A newly created memory handle suitable for reading. nil is returned if the url cannot be read.
 */
- (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)options error:(NSError * _Nullable * _Nullable)error;

/*!
 If the handle is not already writable, the handles data is converted to mutable, making the handle writable. The conversion to writable does not change the position within the data.
 */
- (void)convertToWritable;

/*!
 Accesses the data in a manner that guarantees the data will not be modified by another thread. The access is only safe during the call back to block, so you shouldn't capture the provided data parameter of block.
 
 Note: If the receiver was created with immutable data, this method will be safe. If the receiver is writable, then see the notes on -[AJRMemoryHandle accessMutableData:].
 
 @param block A block that will be called while holding the handle's access lock.
 */
- (void)accessData:(void (^)(NSData *data, NSUInteger * _Nullable position))block;
/*!
 If writable, access the receiver's mutable data. If the receiver is not mutable, this method just return immediately with NO. If the receiver is writable, block will be called with the receiver's mutable data while holding the receiver's internal lock.
 
 Note: This only guarantee's safe access if the receiver's mutable data is not being written to by an outside source. As such, you must be extrememly careful when create a memory handle and make sure that the mutable data passed into the object is not being modified by an outside source. As such, if you need to guarantee thread safety, you should always create your memory handle with a copy of the mutable data you're trying to modify. Or, in the very least, don't use a mutable data from a source where you cannot guarantee when the data will be changed.
 
 @param block A block that will be called while holding the receiver's lock. This doesn't guarantee thread safety if the receiver's mutable data is changed by an external source.
 */
- (BOOL)accessMutableData:(void (^)(NSMutableData *data, NSUInteger * _Nullable position))block;

@property (nonatomic,readonly) NSData *data;
- (NSData *)availableData;
/*! Returns the file's mutable data, if the data is writeable, otherwise returns nil. */
@property (nonatomic,readonly,nullable) NSMutableData *mutableData;
@property (nonatomic,readonly) BOOL canWrite;

- (NSData *)readDataToEndOfFile;
- (NSData *)readDataToEndOfFileWithError:(NSError * _Nullable * _Nullable)error;
- (NSData *)readDataOfLength:(NSUInteger)length;
- (NSData *)readDataOfLength:(NSUInteger)length error:(NSError * _Nullable * _Nullable)error;

- (void)writeData:(NSData *)data;

- (unsigned long long)offsetInFile;
- (unsigned long long)seekToEndOfFile;
- (void)seekToFileOffset:(unsigned long long)offset;

- (void)truncateFileAtOffset:(unsigned long long)offset;
- (void)synchronizeFile;
- (void)closeFile;

- (void)readInBackgroundAndNotifyForModes:(nullable NSArray<NSRunLoopMode> *)modes;
- (void)readInBackgroundAndNotify;

- (void)readToEndOfFileInBackgroundAndNotifyForModes:(nullable NSArray<NSRunLoopMode> *)modes;
- (void)readToEndOfFileInBackgroundAndNotify;

- (void)acceptConnectionInBackgroundAndNotifyForModes:(nullable NSArray<NSRunLoopMode> *)modes;
- (void)acceptConnectionInBackgroundAndNotify;

- (void)waitForDataInBackgroundAndNotifyForModes:(nullable NSArray<NSRunLoopMode> *)modes;
- (void)waitForDataInBackgroundAndNotify;

- (NSInteger)fileDescriptor;

@end

NS_ASSUME_NONNULL_END
