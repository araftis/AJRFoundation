
#import <AJRFoundation/AJRPlugInExtensionPoint.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPlugInAttribute;

@interface AJRPlugInElement : NSObject <AJRPlugInSchemaObject>

@property (nonatomic,strong) NSString *name;
@property (null_resettable,nonatomic,strong) NSString *key; // If nil, return name.
@property (nonatomic,strong) NSString *type;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInAttribute *> *attributes;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInElement *> *elements;
@property (nonatomic,assign) BOOL required;

@end

NS_ASSUME_NONNULL_END
