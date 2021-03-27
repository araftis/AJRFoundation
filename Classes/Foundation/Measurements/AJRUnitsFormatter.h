
#import <Foundation/Foundation.h>

@interface AJRUnitsFormatter : NSFormatter

- (id)init;
- (id)initWithUnits:(NSUnit *)units displayUnits:(NSUnit *)displayUnits;

@property (nonatomic,strong) NSUnit *displayUnits;  // The units used to display the value.
@property (nonatomic,strong) NSUnit *units;         // The units used to set / get the value.

@end
