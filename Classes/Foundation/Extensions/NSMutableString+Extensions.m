
#import "NSMutableString+Extensions.h"

@implementation NSMutableString (AJRExtensions)

- (void)replaceHTMLSpecialCharactersWithEntityNames {
    static NSCharacterSet *set = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		set = [NSCharacterSet characterSetWithCharactersInString:@"<>&"];
	});
    NSRange range;
    NSRange searchRange;    
    
    range = [self rangeOfCharacterFromSet:set];
    while (range.location != NSNotFound) {
        unichar character = [self characterAtIndex:range.location];
        NSString *replacementString = nil;
        
        switch (character) {
            case '<':
                replacementString = @"&lt;";
                break;
            case '>':
                replacementString = @"&gt;";
                break;
            case '&':
                replacementString = @"&amp;";
                break;
        }
        if (replacementString) {
            [self replaceCharactersInRange:range withString:replacementString];
            searchRange.location = range.location + [replacementString length];
            searchRange.length = [self length] - searchRange.location;
            range = [self rangeOfCharacterFromSet:set options:0 range:searchRange];
        }
    }
}

@end
