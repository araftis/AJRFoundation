
#import "NSObject+Extensions.h"

#import "AJRExpression.h"
#import "AJRFunctions.h"
#import "AJRTranslator.h"

#import <objc/message.h>
#import <objc/runtime.h>
#import <AJRFoundation/AJRFoundation.h>

@interface AJRObjectObserver : NSObject

@property (nonatomic,weak) id observedObject;
@property (nonatomic,strong) NSString *keyPath;
@property (nonatomic,assign) NSUInteger options;
@property (nonatomic,strong) AJRObserverBlock block;

- (instancetype)initWithObservedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)block;

@end

@implementation AJRObjectObserver

- (instancetype)initWithObservedObject:(id)observedObject keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock) block {
    if ((self = [super init])) {
        _observedObject = observedObject;
        _keyPath = keyPath;
        _options = options;
        _block = block;
        [_observedObject addObserver:self forKeyPath:keyPath options:options context:NULL];
    }
    return self;
}

- (void)dealloc {
    [_observedObject removeObserver:self forKeyPath:_keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    _block(object, keyPath, change);
}

@end

@implementation NSObject (Extensions)

#pragma mark - Miscellaneous

- (id)copyToSubclass:(Class)subclass {
    id <NSCoding> codableObject = AJRObjectIfConformsToProtocol(self, NSCoding);
    return codableObject != nil ? AJRCopyCodableObject(codableObject, subclass) : nil;
}

#pragma mark Key/Value Expression

- (id)valueForKeyExpression:(NSString *)keyExpression {
    return [[AJRExpression expressionWithString:keyExpression error:NULL] evaluateWithObject:self error:NULL];
}

#pragma mark - Reflection

- (BOOL)overridesSelector:(SEL)selector {
    IMP selfImp = [self methodForSelector:selector];
    IMP superImp = [[self superclass] instanceMethodForSelector:selector];
    
    return selfImp != superImp;
}

+ (BOOL)overridesSelector:(SEL)selector {
    IMP selfImp = [self instanceMethodForSelector:selector];
    IMP superImp = [[self superclass] instanceMethodForSelector:selector];
    
    return selfImp != superImp;
}

- (id)addObserver:(id)object forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(AJRObserverBlock)block {
    return [[AJRObjectObserver alloc] initWithObservedObject:self keyPath:keyPath options:options block:block];
}

@end
