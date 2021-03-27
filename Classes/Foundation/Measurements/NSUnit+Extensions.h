
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUnit (Extensions)

+ (NSUnit *)unitForIdentifier:(NSString *)unitIdentifier;

@property (nonatomic,class,readonly) NSSet<NSString *> *unitIdentifiers;
@property (nonatomic,class,readonly) NSSet<Class> *unitClasses;

@property (nonatomic,readonly) NSString *localizedName;
@property (nonatomic,readonly) NSString *identifier;

@end

@interface NSUnitLength (Extensions)

@property (class,nonatomic,readonly) NSUnitLength *points;
@property (class,nonatomic,readonly) NSUnitLength *picas;

@end

NS_ASSUME_NONNULL_END
