/*
NSBundle+Extensions.m
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
