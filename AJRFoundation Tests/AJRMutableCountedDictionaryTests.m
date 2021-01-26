//
//  AJRMutableCountedDictionaryTests.m
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 11/5/19.
//

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRMutableCountedDictionaryTests : XCTestCase

@end

@implementation AJRMutableCountedDictionaryTests

- (void)testExample {
    AJRMutableCountedDictionary *dictionary;

    dictionary = [[AJRMutableCountedDictionary alloc] init];
    XCTAssert([dictionary isKindOfClass:AJRMutableCountedDictionary.class]);
    [dictionary setObject:@"uno" forKey:@"One"];
    [dictionary setObject:@"dos" forKey:@"Two"];
    [dictionary setObject:@"dos" forKey:@"Two"];

    XCTAssert([dictionary[@"One"] isEqualToString:@"uno"]);
    XCTAssert([dictionary countForKey:@"One"] == 1);
    XCTAssert([dictionary[@"Two"] isEqualToString:@"dos"]);
    XCTAssert([dictionary countForKey:@"Two"] == 2);
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]]) {
            XCTAssert([dictionary countForKey:key] >= 1);
        }
    }];
    
    [dictionary removeObjectForKey:@"One"];
    XCTAssert(dictionary.count == 1 && dictionary[@"One"] == nil);
    [dictionary removeObjectForKey:@"Two"];
    XCTAssert(dictionary.count == 1 && dictionary[@"Two"] != nil);
    [dictionary removeObjectForKey:@"Two"];
    XCTAssert(dictionary.count == 0 && dictionary[@"Two"] == nil);
    
    dictionary = [[AJRMutableCountedDictionary alloc] initWithCapacity:10];
    XCTAssert([dictionary isKindOfClass:AJRMutableCountedDictionary.class]);
    [dictionary setObject:@"uno" forKey:@"One"];
    XCTAssert(dictionary.count == 1 && dictionary[@"One"] != nil);

    id keys[] = { @"One", @"Two", @"Three" };
    id objects[] = { @"uno", @"dos", @"tres" };
    dictionary = [[AJRMutableCountedDictionary alloc] initWithObjects:objects forKeys:keys count:AJRCountOf(keys)];
    XCTAssert([dictionary isKindOfClass:AJRMutableCountedDictionary.class]);
    XCTAssert(dictionary.count == 3 && dictionary[@"One"] != nil);
}

@end
