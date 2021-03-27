
#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface NSUserDefaults_ExtensionsTests : XCTestCase

@end

@implementation NSUserDefaults_ExtensionsTests

- (void)testUnits {
    NSSet<NSString *> *all = [NSUnit unitIdentifiers];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    NSInteger index = 0;
    for (NSString *identifier in all) {
        NSUnit *unit = [NSUnit unitForIdentifier:identifier];
        XCTAssert(unit != nil);
        
        [defaults setUnits:unit forKey:[@(index + 1) description]];

        index += 1;
    }
    
    NSInteger max = index;
    index = 0;
    for (index = 0; index < max; index++) {
        NSUnit *unit = [defaults unitsForKey:[@(index + 1) description] defaultValue:nil];
        XCTAssert(unit != nil);
        index++;
    }
}

- (void)testClasses {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    
    [defaults setClass:[NSString class] forKey:@"test1"];
    XCTAssert([defaults classForKey:@"test1" defaultValue:Nil] != Nil);
    XCTAssert([defaults classForKey:@"test2" defaultValue:NSNumber.class] == NSNumber.class);
    [defaults setObject:@"THIS_ISNT_A_VALID_CLASS" forKey:@"test2"];
    XCTAssert([defaults classForKey:@"test2" defaultValue:NSNumber.class] == NSNumber.class);
    
    [defaults setClass:Nil forKey:@"test1"];
    [defaults setClass:Nil forKey:@"test2"];
}

@end
