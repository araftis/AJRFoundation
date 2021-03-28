/*
NSObject+ExtensionsTests.m
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <XCTest/XCTest.h>

#import <AJRFoundation/AJRFoundation.h>

@interface AJRSimpleObjectForCopyTest1 : NSObject <NSCoding>

@end

@implementation AJRSimpleObjectForCopyTest1

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    return [self init];
}

- (NSString *)description {
    return @"Hi mom!";
}

- (id)selectorOne {
    return @"one";
}

- (id)selectorOneWithTwo:(id)object {
    return AJRFormat(@"one-%@", object);
}

- (id)selectorOneWithTwo:(id)two andThree:(id)three {
    return AJRFormat(@"one-%@-%@", two, three);
}

@end

@interface AJRSimpleObjectForCopyTest2 : AJRSimpleObjectForCopyTest1 <NSCoding>

@end

@implementation AJRSimpleObjectForCopyTest2

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [super encodeWithCoder:coder];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    return [super initWithCoder:coder];
}

- (NSUInteger)hash {
    return 0;
}

@end

@interface NSObject_ExtensionsTests : XCTestCase

@property (nonatomic,strong) id selectedTitle; // For testing purposes.

@end

@implementation NSObject_ExtensionsTests

- (void)testCopying {
    AJRSimpleObjectForCopyTest1 *object = [[AJRSimpleObjectForCopyTest1 alloc] init];
    AJRSimpleObjectForCopyTest1 *copy1 = [object copyToSubclass:nil];
    AJRSimpleObjectForCopyTest1 *copy2 = [object copyToSubclass:[AJRSimpleObjectForCopyTest1 class]];
    AJRSimpleObjectForCopyTest2 *copy3 = (AJRSimpleObjectForCopyTest2 *)[object copyToSubclass:[AJRSimpleObjectForCopyTest2 class]];

    XCTAssert(copy1 != nil);
    XCTAssert([copy1 isKindOfClass:[AJRSimpleObjectForCopyTest1 class]]);
    XCTAssert(copy2 != nil);
    XCTAssert([copy2 isKindOfClass:[AJRSimpleObjectForCopyTest1 class]]);
    XCTAssert(copy3 != nil);
    XCTAssert([copy3 isKindOfClass:[AJRSimpleObjectForCopyTest2 class]]);
}

- (void)testMethodOverrideTesting {
    AJRSimpleObjectForCopyTest1 *object1 = [[AJRSimpleObjectForCopyTest1 alloc] init];
    AJRSimpleObjectForCopyTest1 *object2 = [[AJRSimpleObjectForCopyTest2 alloc] init];

    XCTAssert([object1 overridesSelector:@selector(description)]);
    XCTAssert(![object2 overridesSelector:@selector(description)]);
    XCTAssert(![object1 overridesSelector:@selector(hash)]);
    XCTAssert([object2 overridesSelector:@selector(hash)]);

    XCTAssert([[AJRSimpleObjectForCopyTest1 class] overridesSelector:@selector(description)]);
    XCTAssert(![[AJRSimpleObjectForCopyTest2 class] overridesSelector:@selector(description)]);
    XCTAssert(![[AJRSimpleObjectForCopyTest1 class] overridesSelector:@selector(hash)]);
    XCTAssert([[AJRSimpleObjectForCopyTest2 class] overridesSelector:@selector(hash)]);
}

- (void)testKeyValueExpressions {
    // Expressions are extensively testing in their own unit test. Here we're just making sure we call through correctly to the expression machinery.
    id value = [[[NSObject alloc] init] valueForKeyExpression:@"1 + 1"];
    XCTAssert([value isEqualToNumber:@(2)]);
}

- (void)setSelectedTitle:(id)selectedTitle {
    _selectedTitle = selectedTitle;
}

- (void)testBindings {
    NSArray *content = @[[[NSObject alloc] init], [[NSObject alloc] init], [[NSObject alloc] init], [[NSObject alloc] init]];
    NSArrayController *controller = [[NSArrayController alloc] initWithContent:content];
    
    [self bind:@"selectedTitle" toObject:controller withKeyPath:@"selection.description" options:nil];
    
    controller.selectedObjects = @[content[0]];
    XCTAssert([self selectionTypeForBinding:@"selectedTitle"] == AJRBindingSelectionTypeSingle);
    controller.selectedObjects = @[];
    XCTAssert([self selectionTypeForBinding:@"selectedTitle"] == AJRBindingSelectionTypeNone);
    controller.selectedObjects = @[content[0], content[1]];
    XCTAssert([self selectionTypeForBinding:@"selectedTitle"] == AJRBindingSelectionTypeMultiple);
}

- (void)testSwiftConveniences {
    NSObject *object = [[NSObject alloc] init];
    NSString *prefix = object.descriptionPrefix;
    XCTAssert([prefix isEqualToString:AJRFormat(@"%C: %p", object, object)]);
}

- (void)testSelectorConveniences {
    NSObject *object = [[AJRSimpleObjectForCopyTest1 alloc] init];
    
    XCTAssert([[object ajr_performSelector:@selector(selectorOne)] isEqualToString:@"one"]);
    XCTAssert([[object ajr_performSelector:@selector(selectorOneWithTwo:) withObject:@"two"] isEqualToString:@"one-two"]);
    XCTAssert([[object ajr_performSelector:@selector(selectorOneWithTwo:andThree:) withObject:@"two" withObject:@"three"] isEqualToString:@"one-two-three"]);
}

@end
