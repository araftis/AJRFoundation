//
//  AJRPropertyListCoding.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 5/12/18.
//

#ifndef AJRPropertyListCoding_h
#define AJRPropertyListCoding_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AJRPropertyListCoding <NSObject>

- (id)initWithPropertyListValue:(id)value error:(NSError * _Nullable * _Nullable)error;
- (id)propertyListValue;

@end

@interface NSNumber (AJRPropertyListCoding) <AJRPropertyListCoding>

@end

@interface NSString (AJRPropertyListCoding) <AJRPropertyListCoding>

@end

NS_ASSUME_NONNULL_END

#endif /* AJRPropertyListCoding_h */
