//
//  AJRXMLErrorDecodeObject.h
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 9/30/19.
//

#import <AJRFoundation/AJRFoundation.h>

NS_ASSUME_NONNULL_BEGIN

// This class is designed to throw an exception on decode if value is > 16

@interface AJRXMLErrorDecodeObject : NSObject <AJRXMLCoding, NSCopying>

@property (nonatomic,assign) NSInteger value;

- (id)initWithValue:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
