
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRFractionFormatter : NSFormatter

@property (nonatomic,assign) NSUInteger minimumDenominator;
@property (nullable,nonatomic,strong) NSString *prefix;
@property (nullable,nonatomic,strong) NSString *suffix;

- (double)valueFromFraction:(NSString *)fraction error:(NSError **)error;
- (NSString *)fractionFromValue:(double)value;

@end

NS_ASSUME_NONNULL_END
