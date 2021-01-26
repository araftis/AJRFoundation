//
//  AJRXMLArchiver.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/18/14.
//
//

#import <AJRFoundation/AJRXMLCoder.h>
#import <AJRFoundation/AJRXMLCoding.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRXMLArchiver : AJRXMLCoder

+ (instancetype)archiverWithOutputStream:(NSOutputStream *)outputStream;

// Use these when you want to explicitly name the top level object in the XML archive.
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key toFile:(NSString *)path error:(NSError **)error;
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error;
+ (nullable NSData *)archivedDataWithRootObject:(id <AJRXMLCoding>)rootObject forKey:(nullable NSString *)key;

// Use these when you want the top level element to just use the root object's XML name.
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject toFile:(NSString *)path error:(NSError **)error;
+ (BOOL)archiveRootObject:(id <AJRXMLCoding>)rootObject toOutputStream:(NSOutputStream *)outputStream error:(NSError **)error;
+ (nullable NSData *)archivedDataWithRootObject:(id <AJRXMLCoding>)rootObject;

@end

NS_ASSUME_NONNULL_END
