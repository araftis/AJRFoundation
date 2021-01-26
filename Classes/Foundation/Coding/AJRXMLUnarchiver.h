//
//  AJRXMLUnarchiver.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/18/14.
//
//

#import <AJRFoundation/AJRXMLCoder.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRXMLDecodingErrorDomain;
extern NSString * const AJRXMLDecodingLoggingDomain;

@interface AJRXMLUnarchiver : AJRXMLCoder

+ (nullable Class)classForXMLName:(NSString *)name;

+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream topLevelClass:(nullable Class)class error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithData:(NSData *)data topLevelClass:(nullable Class)class error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithURL:(NSURL *)url topLevelClass:(nullable Class)class error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithStream:(NSInputStream *)stream error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
+ (nullable id)unarchivedObjectWithURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;

@property (nonatomic,assign) BOOL warnOfUndecodedKeys;

@end

NS_ASSUME_NONNULL_END
