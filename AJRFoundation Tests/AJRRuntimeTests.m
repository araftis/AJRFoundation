
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>
#import <objc/Protocol.h>

enum FooManChu { FOO, MAN, CHU };
typedef enum FooManChu FooManChuType;
struct YorkshireTeaStruct { int pot; char lady; };
typedef struct YorkshireTeaStruct YorkshireTeaStructType;
union MoneyUnion { float alone; double down; };

extern void _AJRRunInternalTestsForUnitTesting(void);

NS_ASSUME_NONNULL_BEGIN

@protocol _TestProtocol <NSObject>

@property (nonatomic,strong) NSString *stringProperty;

+ (instancetype)createAnInstance;
@required - (NSInteger)requiredMethodWithParameter:(short)value1 andOther:(double)value2;
- (void)doSomethingWithAnEnum:(FooManChuType)value;
- (void)doSomethingWithAnUnion:(union MoneyUnion)value;

@end

@interface _TestClassWithLotsOfTypes : NSObject <NSCopying, NSCoding, _TestProtocol> {
    @public NSInteger _integerPublicVariable;
    @protected NSInteger _integerProtectedVariable;
    @private NSInteger _integerPrivateVariable;
}

@property (nonatomic,assign) char *cStringProperty;
@property (nonatomic,assign) void *pointerProperty;
@property BOOL boolProperty;
@property (strong) id strongProperty;
@property (weak) id weakProperty;
@property (nonatomic,strong) id nonatomicStrongProperty;
@property (nonatomic,weak) id nonatomicWeakProperty;
@property (nullable,strong) id nullableStrongProperty;
@property (nonnull,strong) id nonnullStrongProperty;
@property (nonatomic,assign) BOOL nonatomicBOOLProperty;
@property (nonatomic,assign) int16_t shortProperty;
@property (nonatomic,assign) int32_t intProperty;
@property (nonatomic,assign) int64_t integerProperty;
@property (nonatomic,assign) float floatProperty;
@property (nonatomic,assign) double doubleProperty;
@property (nonatomic,assign) long double longDoubleProperty;
@property (nonatomic,assign) NSSize sizeProperty;
@property (nonatomic,assign) NSPoint pointProperty;
@property (nonatomic,assign) NSRect rectProperty;
@property (nonatomic,assign) NSRange rangeProperty;
@property (nonatomic,strong) void (^blockProperty)(BOOL success);
@property (nonatomic,assign) int (*functionPointerProperty)(char *);
@property (nonatomic,assign) union MoneyUnion unionProperty;
@property (nonatomic,assign) YorkshireTeaStructType structTypeProperty;
@property (nonatomic,assign) struct YorkshireTeaStruct structProperty;
@property (nonatomic,assign) enum FooManChu enumProperty;
@property (nonatomic,assign) FooManChuType enumTypeProperty;
@property (nonatomic,class,assign) NSInteger classIntegerProperty;
@property (nonatomic,assign) SEL actionProperty;
@property (nonatomic,getter=lizard,setter=setLizard:,strong) id iguana;

@end

NS_ASSUME_NONNULL_END

@implementation _TestClassWithLotsOfTypes

@dynamic classIntegerProperty;

+ (instancetype)createAnInstance {
    return [[self alloc] init];
}

- (NSInteger)requiredMethodWithParameter:(short)value1 andOther:(double)value2 {
    return 0;
}

- (void)doSomethingWithAnEnum:(FooManChuType)value {
}


- (void)doSomethingWithAnUnion:(union MoneyUnion)value {
}

- (void)voidMethod {
}

- (void)setCharMethod:(char)value {
}

- (char)charMethod {
    return 'c';
}

- (void)setUnsignedCharMethod:(unsigned char)value {
}

- (unsigned char)unsignedCharMethod {
    return 'C';
}

- (void)setShortMethod:(short)value {
}

- (int16_t)shortMethod {
    return 0;
}

- (void)setUnsignedShortMethod:(unsigned short)value {
}

- (uint16_t)unsignedShortMethod {
    return 0;
}

- (void)setIntMethod:(int32_t)value {
}

- (int32_t)intMethod {
    return 0;
}

- (void)setUnsignedIntMethod:(uint32_t)value {
}

- (uint32_t)unsignedIntMethod {
    return 0;
}

- (void)setIntegerMethod:(int64_t)value {
}

- (int64_t)integerMethod {
    return 0;
}

- (void)setUnsignedIntegerMethod:(uint64_t)value {
}

- (uint64_t)unsignedIntegerMethod {
    return 0;
}

- (void)setFloatMethod:(float)value {
}

- (float)floatMethod {
    return 0.0;
}

- (void)setDoubleMethod:(double)value {
}

- (double)doubleMethod {
    return 0.0;
}

- (void)setLongDoubleMethod:(long double)value {
}

- (long double)longDoubleMethod {
    return 0.0;
}

- (void)setObjcetMethod:(id)value {
}

- (id)objectMethod {
    return 0;
}

- (void)setSizeMethod:(NSSize)value {
}

- (NSSize)sizeMethod {
    return NSZeroSize;
}

- (void)setPointMethod:(NSPoint)value {
}

- (NSPoint)pointMethod {
    return NSZeroPoint;
}

- (void)setRectMethod:(NSRect)value {
}

- (NSRect)rectMethod {
    return NSZeroRect;
}

- (void)setRangeMethod:(NSRange)value {
}

- (NSRange)rangeMethod {
    return (NSRange){NSNotFound, 0};
}

- (void)bigMethodWithBOOLValue:(BOOL)v1 shortValue:(uint16_t)v2 intValue:(uint32_t)v3 integerValue:(uint64_t)v4 floatValue:(float)v5 doubleValue:(double)v6 {
}

- (void)doSomethingWithCompletionHandler:(void (^)(BOOL success))completionHandler {
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    return [self init];
}

@synthesize stringProperty;

- (void)setActionMethod:(SEL)anAction {
}

- (SEL)action {
    return _cmd;
}

@end

@interface AJRRuntimeTests : XCTestCase

@end

@implementation AJRRuntimeTests

- (void)testClassEnumeration {
    AJRClassEnumerator *classEnumerator = [AJRClassEnumerator classEnumerator];
    Class class = Nil;
    NSMutableSet *classesToCheckFor = [NSMutableSet setWithArray:@[[NSObject class], [AJRClassEnumerator class], [NSString class]]];
    
    // Use nextObject, because it forces use of nextObject and nextClass.
    while ((class = [classEnumerator nextObject]) != nil) {
        [classesToCheckFor removeObject:class];
    }
    XCTAssert([classesToCheckFor count] == 0);
    
    Class *classes;
    NSUInteger count;
    [AJRClassEnumerator getClasses:&classes count:&count];
    XCTAssert(classes != nil && count > 0);
    free(classes);
}

- (void)testMethodEnumeration {
    AJRMethodEnumerator *methodEnumerator = [AJRMethodEnumerator methodEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    Method method;
    
    NSMutableSet *expected = [NSMutableSet setWithArray:@[@"sizeMethod", @"description"]];
    [methodEnumerator setEnumerateSuperclasses:YES];
    while ((method = [methodEnumerator nextMethod]) != nil) {
        [expected removeObject:NSStringFromSelector(method_getName(method))];
    }
    XCTAssert([expected count] == 0, @"We didn't find all expected methods: %@", expected);
    
    XCTAssert([methodEnumerator nextMethod] == NULL, @"Hum. We got a result after we should have been done.");

    // Repeat using nextObject, the less desirable interface.
    methodEnumerator = [AJRMethodEnumerator methodEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    for (NSValue *methodValue in methodEnumerator) {
        method = [methodValue pointerValue];
        AJRPrintf(@"%@\n", AJRStringFromMethod(method, [methodEnumerator isClassMethod]));
    }
    
    XCTAssert([methodEnumerator nextMethod] == NULL, @"Hum. We got a result after we should have been done.");
}

- (void)testPropertyEnumerator {
    AJRPropertyEnumerator *propertyEnumerator = [AJRPropertyEnumerator propertyEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    
    NSInteger count = 0, countWithSuper = 0;
    objc_property_t property;
    while ((property = [propertyEnumerator nextProperty])) {
        AJRPrintf(@"%@\n", AJRStringFromProperty(property, [propertyEnumerator isClassProperty]));
        count++;
    }

    propertyEnumerator = [AJRPropertyEnumerator propertyEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    [propertyEnumerator setEnumeratesSuperclasses:YES];
    NSValue *propertyValue;
    while ((propertyValue = [propertyEnumerator nextObject])) {
        AJRPrintf(@"%@\n", AJRStringFromProperty([propertyValue pointerValue], [propertyEnumerator isClassProperty]));
        countWithSuper++;
    }
    XCTAssert([propertyEnumerator nextObject] == nil, @"Hum, we went past the end?");
    
    XCTAssert(count != countWithSuper);
}

- (void)testVariableEnumerator {
    AJRVariableEnumerator *variableEnumerator = [AJRVariableEnumerator variableEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    [variableEnumerator setEnumerateSuperclasses:YES];
    NSValue *variableValue;
    while ((variableValue = [variableEnumerator nextObject])) {
        Ivar variable = [variableValue pointerValue];
        AJRPrintf(@"%B %@\n", [variableEnumerator isClassVariable], AJRStringFromVariable(variable));
    }
    // Try to go past the end
    XCTAssert([variableEnumerator nextObject] == nil);
}

- (void)testProtocolEnumeration {
    AJRProtocolEnumerator *protocolEnumerator = [AJRProtocolEnumerator protocolEnumeratorWithClass:[_TestClassWithLotsOfTypes class]];
    NSDictionary *expectedCounts = @{@"NSCopying":@(0), @"NSCoding":@(0), @"_TestProtocol":@(1)};
    
    Protocol *protocol;
    while ((protocol = [protocolEnumerator nextObject])) {
        AJRPrintf(@"%@\n", AJRStringFromProtocol(protocol));
        
        AJRProtocolMethodEnumerator *methodEnumerator = [AJRProtocolMethodEnumerator methodEnumeratorWithProtocol:protocol];
        AJRPrintf(@"    Methods:\n");
        NSValue *methodValue; // Use the less ideal interface, because it also uses the more ideal interface.
        while ((methodValue = [methodEnumerator nextObject])) {
            struct objc_method_description *method = [methodValue pointerValue];
            AJRPrintf(@"        %@\n", AJRStringFromMethodDescription(*method, [methodEnumerator isClassMethod], [methodEnumerator isRequired]));
        }
        
        AJRProtocolPropertyEnumerator *propertyEnumerator = [AJRProtocolPropertyEnumerator propertyEnumeratorWithProtocol:protocol];
        AJRPrintf(@"    Properties:\n");
        NSValue *propertyValue;
        NSInteger count = 0;
        while ((propertyValue = [propertyEnumerator nextObject])) {
            objc_property_t property = [propertyValue pointerValue];
            AJRPrintf(@"        %@\n", AJRStringFromProperty(property, [propertyEnumerator isClassProperty]));
            count++;
        }
        
        XCTAssert(count == [[expectedCounts objectForKey:AJRStringFromProtocol(protocol)] integerValue]);
    }
}

- (void)testInterfaceDump {
    NSString *result = AJRClassInterfaceFromClass([_TestClassWithLotsOfTypes class]);
    XCTAssert(result != nil);
    AJRPrintf(@"%@\n", result);
}

- (void)testMisc {
    // This throws hard ajrsertions on failure.
    _AJRRunInternalTestsForUnitTesting();
}

- (void)testInheritanceLookups {
    NSArray<Class> *classes = AJRClassesInheritingFromClass([NSValue class], NO);
    XCTAssert([classes containsObject:[NSNumber class]]);
    XCTAssert([classes containsObject:[NSDecimalNumber class]]);
    XCTAssert(![classes containsObject:[NSValue class]]);

    classes = AJRClassesInheritingFromClass([NSValue class], YES);
    XCTAssert([classes containsObject:[NSNumber class]]);
    XCTAssert([classes containsObject:[NSDecimalNumber class]]);
    XCTAssert([classes containsObject:[NSValue class]]);
}

@end

