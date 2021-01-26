//
//  NSKeyedArchiver+Extensions.m
//  AJRFoundation
//
//  Created by AJ Raftis on 12/17/20.
//

#import "NSKeyedArchiver+Extensions.h"

@implementation NSKeyedArchiver (Extensions)

+ (NSData *)ajr_archivedObject:(id <NSCoding>)object error:(NSError **)error {
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];

    [archiver encodeObject:object forKey:@"__ROOT__"];
    [archiver finishEncoding];

    return archiver.encodedData;
}

@end
