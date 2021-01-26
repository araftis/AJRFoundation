//
//  AJRSimpleTestClass.h
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 10/29/19.
//

#import <AJRFoundation/AJRFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRSimpleTestClass : NSObject <AJRPropertyListCoding, AJRXMLCoding, NSCopying>

+ (id)objectWithStringValue:(NSString *)stringValue;
+ (id)objectWithIntegerValue:(NSInteger)integerValue;
+ (id)objectWithFloatValue:(float)floatValue;
+ (id)objectWithDoubleValue:(double)doubleValue;
+ (id)objectWithBOOLValue:(BOOL)boolValue;

@property (nonatomic,strong) NSString *stringValue;
@property (nonatomic,assign) NSInteger integerValue;
@property (nonatomic,assign) float floatValue;
@property (nonatomic,assign) double doubleValue;
@property (nonatomic,assign) BOOL boolValue;

- (void)setStringByConcatenating:(NSString *)first with:(NSString *)second;

@end

NS_ASSUME_NONNULL_END
