
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPlugInAttribute, AJRPlugInElement, AJRPlugInExtensionPoint, AJRPlugInExtension;

extern NSString * const AJRPlugInManagerLoggingDomain;
extern NSString * const AJRPlugInManagerErrorDomain;

typedef id _Nullable (^AJRPlugInValueTransformer)(NSString *rawValue, NSBundle * _Nullable bundle, NSError * _Nullable * _Nullable error);

extern void AJRRegisterPluinTransformer(NSString *type, AJRPlugInValueTransformer transformer);

@interface AJRPlugInManager : NSObject

/*! Does the initial setup of the plugin manager. */
+ (void)initializePlugInManager;

@property (nonatomic,class,readonly) AJRPlugInManager *sharedPlugInManager NS_SWIFT_NAME(shared);

- (void)registerExtensionPoint:(NSString *)factoryClassName
                      withName:(NSString *)name
        registrySelectorString:(nullable NSString *)registrySelectorString
                    attributes:(NSDictionary<NSString *, AJRPlugInAttribute *> *)attributes
                      elements:(NSDictionary<NSString *, AJRPlugInElement *> *)elements;

- (nullable AJRPlugInExtensionPoint *)extensionPointForClass:(Class)class;
- (nullable AJRPlugInExtensionPoint *)extensionPointForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
