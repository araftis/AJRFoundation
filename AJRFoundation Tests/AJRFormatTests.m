/*
 AJRFormatTests.m
 AJRFoundation

 Copyright © 2022, AJ Raftis and AJRFoundation authors
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

@interface AJRFormatTest : XCTestCase

@end

@implementation AJRFormatTest

- (void)testFormat:(NSString *)format, ... {
    va_list ap;
    
    va_start(ap, format);
    NSString *left = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    va_start(ap, format);
    NSString *right = AJRFormatv(format, ap);
    va_end(ap);
    
    XCTAssert([left isEqualToString:right], @"NSString's implementation != AJRFormat's implementation: '%@' vs. '%@'. Format string was '%@'.", left, right, format);
}

- (void)test:(NSString *)expectedResult vsFormat:(NSString *)format, ...
{
    va_list ap;
    
    va_start(ap, format);
    NSString *formatted = AJRFormatv(format, ap);
    va_end(ap);
    
    XCTAssert([expectedResult isEqualToString:formatted], @"String != AJRFormat's implementation: '%@' vs. '%@'. Format string was '%@'.", expectedResult, formatted, format);
}

- (void)testBasicTypes {
    [self testFormat:@"%c", (char)123456];
    [self testFormat:@"%lc", (char)123456];
    [self testFormat:@"%d", (int)123456];
    [self testFormat:@"%#d", (int)123456];
    [self testFormat:@"%d", (int)0];
    [self testFormat:@"%05d", (int)123];
    [self testFormat:@"%05d", (int)-123];
    [self testFormat:@"%-5d", (int)123];
    [self testFormat:@"%#08x", (int)0xDEAD];
    [self testFormat:@"%#8x", (int)0xDEAD];
    [self testFormat:@"%#+8d", (int)12345];
    [self test:@"+0xdead" vsFormat:@"%#+x", (int)0xDEAD];
    [self testFormat:@"%hd", (int)12345];
    [self testFormat:@"%hd", (int)-12345];
    [self testFormat:@"%hu", (int)12345];
    [self testFormat:@"%o", (int)123456];
    [self testFormat:@"%#o", (int)123456];
    [self testFormat:@"%x", (int)123456];
    [self testFormat:@"%#x", (int)123456];
    [self testFormat:@"%X", (int)123456];
    [self testFormat:@"%#X", (int)123456];
    [self testFormat:@"% d", (int)123456];
    [self testFormat:@"%+d", (int)123456];
    [self testFormat:@"%+d", (int)-123456];
    [self testFormat:@"%*d", 10, (int)123456];
    [self testFormat:@"%.*d", 10, (int)123456];
    [self testFormat:@"%ld", (long)123456];
    [self testFormat:@"%lld", (long long)1234567890123456789LL];
    [self testFormat:@"%lld", (long long)-1234567890123456789LL];
    [self testFormat:@"%qd", (long long)1234567890123456789LL];
    [self testFormat:@"%ld", (long)-123456];
    [self testFormat:@"%o", (int)123456];
    [self testFormat:@"%lo", (long)123456];
    [self test:@"11110001001000000" vsFormat:@"%b", (int)123456];
    [self testFormat:@"%u", (int)123456];
    [self testFormat:@"%lu", (long)123456];
    [self testFormat:@"%x", (int)123456];
    [self testFormat:@"%lx", (long)123456];
    [self testFormat:@"%X", (int)123456];
    [self testFormat:@"%lX", (long)123456];
    [self testFormat:@"%f", (float)123.456];
    [self testFormat:@"%F", (float)123.456];
    [self testFormat:@"%e", (float)123.456];
    [self testFormat:@"%E", (float)123.456];
    [self testFormat:@"%g", (float)123.456];
    [self testFormat:@"%G", (float)123.456];
    [self testFormat:@"%a", (float)123.456];
    [self testFormat:@"%A", (float)123.456];
    [self testFormat:@"%e", (float)123456789.123456789];
    [self testFormat:@"%E", (float)123456789.123456789];
    [self testFormat:@"%g", (float)123456789.123456789];
    [self testFormat:@"%G", (float)123456789.123456789];
    [self testFormat:@"%LG", (float)123456789.123456789];
    [self testFormat:@"%*LG", 10, (float)123456789.123456789];
    [self testFormat:@"%.*LG", 10, (float)123456789.123456789];
    [self testFormat:@"%*.*LG", 10, 10, (float)123456789.123456789];
    [self testFormat:@"%a", (float)123456789.123456789];
    [self testFormat:@"%A", (float)123456789.123456789];
    [self testFormat:@"%s", "Alex"];
    [self testFormat:@"%s", NULL];
    [self testFormat:@"%ls", NULL];
    [self testFormat:@"%.1f%%", 0.50 * 100.0];
    [self testFormat:@"%- #01.1f", M_PI];
    [self testFormat:@"%-+#01.1f", M_PI];
    [self testFormat:@"%*f", 5, M_PI];
    [self testFormat:@"%.*f", 5, M_PI];
    [self testFormat:@"%*.*f", 5, 5, M_PI];
    [self testFormat:@"%@", self];
    [self testFormat:@"%@", nil];
    [self testFormat:@"%p", self];
    XCTAssert([AJRFormat(@"%99.99s", "alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex alex ") length] == 99, @"String wasn't padded to 99 characters.");
    [self test:@"00:01:40" vsFormat:@"%T", 100.45];
    [self test:@"00:01:40" vsFormat:@"%T", 100.45678];
    [self test:@"00:01:40.46" vsFormat:@"%.2T", 100.45678];
    [self test:@"576:00:00" vsFormat:@"%T", (NSTimeInterval)(60*60*24*24)];
    [self test:@"-00:01:40" vsFormat:@"%T", -100.45];
    [self test:@"00:05:00" vsFormat:@"%T", (NSTimeInterval)(60*5)];
    [self test:@"00:15:00" vsFormat:@"%T", (NSTimeInterval)(60*15)];
    [self test:@"00:00:00.50000" vsFormat:@"%.5T", 0.5];
    [self test:@"00:00:00.00005" vsFormat:@"%.5T", 0.00005];
    [self test:@"ABCD" vsFormat:@"%O", 'ABCD'];
    [self testFormat:@"%v", 10];
    [self test:@"😃😀😄" vsFormat:@"😃%lc😄", 0x1F600];

    size_t sizeTTest = 1234;
    [self testFormat:@"%z", sizeTTest];
    
    // These are all extensions to unicode formatting. In the end, we wind up handling this slightly different than NSString or printf, because as things are, they both disagree.
    NSMutableData *data = [[@"Alex" dataUsingEncoding:NSUTF16StringEncoding] mutableCopy];
    char nullBytes[2] = {0, 0};
    NSData *null = [NSData dataWithBytes:nullBytes length:2];
    [data appendData:null];
    XCTAssert([@"Alex" isEqualToString:AJRFormat(@"%ls", [data bytes])]);
    unsigned char le[] = { 0xFF, 0xFE };
    unsigned char be[] = { 0xFE, 0xFF };
    data = [NSMutableData data];
    [data appendBytes:le length:2];
    [data appendData:[@"Alex" dataUsingEncoding:NSUTF16LittleEndianStringEncoding]];
    [data appendData:null];
    XCTAssert([@"Alex" isEqualToString:AJRFormat(@"%ls", [data bytes])]);
    data = [NSMutableData data];
    [data appendBytes:be length:2];
    [data appendData:[@"Alex" dataUsingEncoding:NSUTF16BigEndianStringEncoding]];
    [data appendData:null];
    XCTAssert([@"Alex" isEqualToString:AJRFormat(@"%ls", [data bytes])]);
    
    [self test:@"Al" vsFormat:@"%.2ls", [data bytes]];
    [self test:@"Alex    " vsFormat:@"%-8ls", [data bytes]];
    [self test:@"    Alex" vsFormat:@"%8ls", [data bytes]];
    [self test:@"Al" vsFormat:@"%.2@", @"Alex"];
    
    // Everything below here is an extension to standard formatting.
    XCTAssert([NSStringFromSelector(_cmd) isEqualToString:AJRFormat(@"%S", _cmd)]);
    XCTAssert([NSStringFromClass([self class]) isEqualToString:AJRFormat(@"%C", [self class])]);
    XCTAssert([NSStringFromClass([self class]) isEqualToString:AJRFormat(@"%C", self)]);
    [self test:@"(Nil)" vsFormat:@"%C", Nil];
    
    [self test:@"10 bytes" vsFormat:@"%m", 10];
    [self test:@"1 KB" vsFormat:@"%m", 1500];
    [self test:@"1.4 MB" vsFormat:@"%m", 1500000];
    [self test:@"1.4 GB" vsFormat:@"%m", 1500000000];
    [self test:@"1.36 TB" vsFormat:@"%m", 1500000000000];
    [self test:@"1.33 PB" vsFormat:@"%m", 1500000000000000];
    [self test:@"1.3 EB" vsFormat:@"%m", 1500000000000000000];

    NSRect testRect = (NSRect){{0.0, 10.0}, {20.0, 30.0}};
    XCTAssert([NSStringFromRect(testRect) isEqualToString:AJRFormat(@"%R", testRect)]);
    
    NSSize testSize = testRect.size;
    XCTAssert([NSStringFromSize(testSize) isEqualToString:AJRFormat(@"%Z", testSize)]);
    
    NSPoint testPoint = testRect.origin;
    XCTAssert([NSStringFromPoint(testPoint) isEqualToString:AJRFormat(@"%P", testPoint)]);

    [self test:@"{10, 20}" vsFormat:@"%r", (NSRange){10, 20}];

    XCTAssert([@"YES" isEqualToString:AJRFormat(@"%B", YES)]);
    XCTAssert([@"NO" isEqualToString:AJRFormat(@"%B", NO)]);
    
    [self testFormat:@"%20s", "Alex"];
    [self testFormat:@"%-20s", "Alex"];
    // NSString doesn't pad %@ formatters.
    [self test:@"                Alex" vsFormat:@"%20@", @"Alex"];
    [self test:@"Alex                " vsFormat:@"%-20@", @"Alex"];
    
    // I think my implementation is more correct, so I'm keeping it...
    [self test:@"0000a" vsFormat:@"%05s", "a"];
    
    // Test forcing the buffer to larger...
    [self testFormat:@"%2000s", "This is a long string that'll be padded."];
    
    // The weird one, %n
    int offset;
    AJRFormat(@"alex%n raftis", &offset);
    XCTAssert(offset == 4);
    NSInteger longOffset;
    AJRFormat(@"alex%ln raftis", &longOffset);
    XCTAssert(longOffset == 4);
    long long longLongOffset;
    AJRFormat(@"alex%lln raftis", &longLongOffset);
    XCTAssert(longLongOffset == 4);
    
    // Appending trailing string portions.
    [self test:@"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
      vsFormat:@"%@"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790"
     @"123456790123456790123456790123456790123456790123456790123456790123456790", @""];
    
    AJRPrintf(@"This is a test of %@.\n", @"printing");
    
    NSString *longString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut in semper dolor. Maecenas interdum est turpis, in gravida sem tincidunt ut. Nullam justo ante, mattis ut metus consectetur, consectetur vestibulum mi. Quisque efficitur elit ac consectetur varius. Nulla id erat odio. Etiam nulla quam, sagittis sit amet diam nec, efficitur ultricies ante. Suspendisse posuere lacus non nisl pretium, vitae congue odio laoreet. Nam eu arcu in nisl laoreet tempor vitae id felis. Donec fermentum erat quis sem venenatis ullamcorper. Praesent faucibus quam nec massa fermentum, finibus porta odio hendrerit. Etiam eget nisi pellentesque, tempus elit nec, commodo orci. Sed id nunc consectetur, scelerisque felis sed, laoreet ipsum. Curabitur et fermentum quam, sed posuere lacus. Donec eget felis ligula.\n\nProin in imperdiet tortor. Ut commodo arcu non dapibus convallis. Praesent vehicula leo vitae laoreet venenatis. Ut leo nibh, condimentum tempus aliquam et, rhoncus eu metus. Mauris bibendum condimentum arcu eget tincidunt. Nullam porttitor sollicitudin magna, in feugiat augue mollis at. Integer interdum ante vel libero maximus ultrices. Donec mollis ante mauris, quis tristique magna venenatis quis. Donec vel hendrerit velit, ut vehicula elit. Sed vestibulum nisi tellus, non aliquet ante blandit vel. Vestibulum suscipit, felis tempus vehicula eleifend, eros sapien blandit quam, ac luctus arcu massa eget nunc. Vestibulum ac accumsan ante, nec sollicitudin ex. Phasellus varius arcu eget tellus eleifend imperdiet. Etiam feugiat ullamcorper sem eu euismod.\n\nAenean est nisl, cursus ut iaculis non, eleifend at odio. Quisque et aliquet turpis. Fusce sed neque turpis. Aliquam gravida arcu vitae feugiat condimentum. Maecenas facilisis tempus dolor sollicitudin porttitor. Nulla et auctor dolor, at condimentum risus. Fusce nec ante sed lectus maximus dictum scelerisque vitae orci. Praesent id erat pharetra, fringilla erat eu, tristique arcu. Donec nec odio risus.\n";
    [self testFormat:@"Test long string: %@", longString];

}

- (void)testDates {
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-8*60*60];
    NSDate *date = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone];
    [self test:@"1971/06/16 12:00" vsFormat:@"%!D", timeZone, date];
    [self test:@"1971-06-16T12:00:00-08:00" vsFormat:@"%!(yyyy-MM-dd'T'HH:mm:ssZZZZZ)D", timeZone, date];

    timeZone = [NSTimeZone localTimeZone];
    date = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone];
    [self test:@"1971/06/16 12:00" vsFormat:@"%D", date];
    // We're purposefully not testing with the time zone here, because it can bounce between daylight and non-daylight time.
    [self test:@"1971-06-16T12:00:00" vsFormat:@"%(yyyy-MM-dd'T'HH:mm:ss)D", date];

    // Now with error logging
    NSOutputStream *warningStream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(warningStream, AJRLogLevelWarning);
    timeZone = [NSTimeZone localTimeZone];
    date = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone];
    [self test:@"1971-06-16T12:00:00" vsFormat:@"%!(yyyy-MM-dd'T'HH:mm:ss)D", [[NSObject alloc] init], date];
    XCTAssert([[warningStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"<WARNING>: Flag parameter to AJRFormatv wasn't an NSTimeZone object.\n"]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);

    warningStream = [NSOutputStream outputStreamToMemory];
    AJRLogSetOutputStream(warningStream, AJRLogLevelWarning);
    timeZone = [NSTimeZone localTimeZone];
    date = [NSDate dateWithYear:1971 month:6 day:16 hour:12 minute:0 second:0 timeZone:timeZone];
    [self test:@"" vsFormat:@"%D", [[NSObject alloc] init]];
    XCTAssert([[warningStream ajr_dataAsStringUsingEncoding:NSUTF8StringEncoding] isEqualToString:@"<WARNING>: Parameter to AJRFormatv wasn't an NSDate object.\n"]);
    AJRLogSetOutputStream(nil, AJRLogLevelWarning);
}

@end
