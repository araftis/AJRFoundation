//
//  NSBundle+Extensions.m
//  AJRFoundation
//
//  Created by A.J. Raftis on 12/1/08.
//  Copyright 2008 A.J. Raftis. All rights reserved.
//

#import "NSBundle+Extensions.h"

#import "AJRFunctions.h"
#import "AJRLogging.h"

#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/ldsyms.h>

@implementation NSBundle (Extensions)

+ (NSBundle *)bundleWithName:(NSString *)name in:(NSArray *)bundles {
    for (NSBundle *bundle in bundles) {
        NSString *path = [bundle bundlePath];
        if ([[[path lastPathComponent] stringByDeletingPathExtension] isEqualToString:name]) {
            return bundle;
        }
    }
    
    return nil;
}

+ (NSBundle *)bundleWithName:(NSString *)name {
    NSBundle *bundle;
    
    bundle = [self bundleWithName:name in:[NSBundle allBundles]];
    if (bundle == nil) {
        bundle = [self bundleWithName:name in:[NSBundle allFrameworks]];
    }
    if (bundle == nil) {
        bundle = [self bundleWithIdentifier:name];
    }
    
    return bundle;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type in:(NSArray *)bundles {
    for (NSBundle *bundle in bundles) {
        NSString *path = [bundle pathForResource:name ofType:type];
        
        if (path) {
            return path;
        }
    }
    
    return nil;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type {
    NSString *path = [self pathForResource:name ofType:type in:[self allBundles]];
    if (path == nil) {
        path = [self pathForResource:name ofType:type in:[self allFrameworks]];
    }
    return path;
}

- (const struct mach_header_64 *)machOHeaderWithSlide:(intptr_t *)slide {
	const struct mach_header_64 *header = NULL;
	
	// Make sure we're a bundle with actual executable code.
	if (self.executablePath != nil) {
		if (!self.isLoaded) {
			[self load];
		}
		
		const char *path = [[[self executablePath] stringByResolvingSymlinksInPath] cStringUsingEncoding:NSUTF8StringEncoding];
		for (uint32_t x = 0; x < _dyld_image_count() && header == NULL; x++) {
			if (strcmp(_dyld_get_image_name(x), path) == 0) {
				if (slide != NULL) {
					*slide = _dyld_get_image_vmaddr_slide(x);
				}
				header = (const struct mach_header_64 *)_dyld_get_image_header(x);
			}
		}
	}
	
	return header;
}

- (NSData *)machOTextDataNamed:(NSString *)name {
    return [self machODataOfType:@"__TEXT" named:name];
}

extern const struct mach_header_64 *_NSGetMachExecuteHeader(void);

- (NSData *)machODataOfType:(NSString *)type named:(NSString *)name {
	NSData *data = nil;
	intptr_t slide = 0;
	const struct mach_header_64 *header = [self machOHeaderWithSlide:&slide];
	
	if (header) {
		uint64_t length;
		const char *segname = [type cStringUsingEncoding:NSUTF8StringEncoding];
		const char *sectname = [name cStringUsingEncoding:NSUTF8StringEncoding];
		const char *bytes = getsectdatafromheader_64(header, segname, sectname, &length);
		
		if (bytes != NULL) {
			data = [NSData dataWithBytes:bytes + slide length:length];
		} else {
			AJRLog(nil, AJRLogLevelWarning, @"Failed to find section named \"%@\" in segment \"%@\" in header %p.", name, type, header);
		}
	} else {
		AJRLog(nil, AJRLogLevelWarning, @"Failed to find executable or framework for %@. The framework or executable is likely unloaded or not referenced by the calling executable.", self);
	}
	
	return data;
}

@end
