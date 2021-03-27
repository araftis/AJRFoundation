
#import <AJRFoundation/AJRXMLCoding.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRXMLCollectionPlaceholder : NSObject <AJRXMLDecoding> {
    Class _finalClass;
    
    id __strong *_objects;
    NSInteger _index;
    NSInteger _max;
}

- (id)initWithFinalClass:(Class)finalClass;

- (void)appendObject:(id)object;

@end

NS_ASSUME_NONNULL_END
