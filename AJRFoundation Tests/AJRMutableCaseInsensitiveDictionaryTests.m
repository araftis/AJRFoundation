
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRMutableCaseInsensitiveDictionaryTests : XCTestCase

@end

@implementation AJRMutableCaseInsensitiveDictionaryTests

- (void)testAll {
    AJRMutableCaseInsensitiveDictionary *dictionary;
    
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] init];
    [dictionary setObject:@"uno" forKey:@"One"];
    [dictionary setObject:@"dos" forKey:@"Two"];
    [dictionary setObject:@"tres" forKey:@(3)];

    XCTAssert([[dictionary objectForKey:@"one"] isEqualToString:@"uno"]);
    XCTAssert([[dictionary objectForKey:@"two"] isEqualToString:@"dos"]);
    XCTAssert([[dictionary objectForKey:@(3)] isEqualToString:@"tres"]);
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]]) {
            XCTAssert([[dictionary objectForKey:[key uppercaseString]] isEqualToString:[dictionary objectForKey:key]]);
        }
    }];
    
    [dictionary removeObjectForKey:@(3)];
    [dictionary removeObjectForKey:@"one"];
    XCTAssert(dictionary.count == 1 && dictionary[@"two"] != nil);
    
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] initWithCapacity:10];
    XCTAssert([dictionary isKindOfClass:AJRMutableCaseInsensitiveDictionary.class]);
    [dictionary setObject:@"uno" forKey:@"One"];
    XCTAssert(dictionary.count == 1 && dictionary[@"One"] != nil);

    id keys[] = { @"One", @"Two", @"Three" };
    id objects[] = { @"uno", @"dos", @"tres" };
    dictionary = [[AJRMutableCaseInsensitiveDictionary alloc] initWithObjects:objects forKeys:keys count:AJRCountOf(keys)];
    XCTAssert(dictionary.count == 3 && dictionary[@"One"] != nil);
}

@end
