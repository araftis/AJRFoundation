
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRPlugInExtension, AJRPlugInAttribute, AJRPlugInElement, AJRPlugInElement;

@protocol AJRPlugInSchemaObject <NSObject>

@property (nonatomic,readonly) NSString *name;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInAttribute *> *attributes;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInElement *> *elements;

- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName;
- (AJRPlugInElement *)elementForName:(NSString *)elementName;

@end

@interface AJRPlugInExtensionPoint : NSObject <AJRPlugInSchemaObject>

@property (nonatomic,assign) BOOL registered;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) Class extensionPointClass;
@property (nonatomic,assign) SEL registrySelector;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInAttribute *> *attributes;
@property (nonatomic,copy) NSDictionary<NSString *, AJRPlugInElement *> *elements;
@property (nonatomic,strong) NSArray<AJRPlugInExtension *> *extensions;

- (void)addExtension:(AJRPlugInExtension *)extension;

- (nullable id)valueForProperty:(NSString *)property onExtensionForClass:(Class)extensionClass;
- (nullable id)valueForProperty:(NSString *)property onExtension:(NSString *)extensionNameOrClassName;

- (nullable AJRPlugInExtension *)extensionForClass:(Class)class;
- (nullable AJRPlugInExtension *)extensionForClassName:(NSString *)className;
- (nullable AJRPlugInExtension *)extensionForName:(NSString *)name;

/*! Returns an AJRPlugInAttribute or AJRPlugInElement. Maybe these should be merged? */
- (id)propertyForName:(NSString *)name;
- (AJRPlugInAttribute *)attributeForName:(NSString *)attributeName;
- (AJRPlugInElement *)elementForName:(NSString *)elementName;

@end

NS_ASSUME_NONNULL_END
