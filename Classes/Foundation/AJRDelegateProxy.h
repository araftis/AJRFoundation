
#import <Foundation/Foundation.h>

@interface AJRDelegateProxy : NSProxy

+ (instancetype)delegateProxyWithDelegate:(id)delegate andInterloper:(id)interloper;
+ (instancetype)delegateProxyWithDelegate:(id)delegate andInterloper:(id)interloper returnValuesFromInterloper:(BOOL)flag;

@property (nonatomic,assign) BOOL returnValuesFromInterloper;
@property (nonatomic,weak) id delegate;
@property (nonatomic,weak) id interloper;

@end
