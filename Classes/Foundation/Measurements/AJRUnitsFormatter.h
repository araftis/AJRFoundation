/*
 AJRUnitsFormatter.h
 AJRFoundation

 Copyright © 2023, AJ Raftis and AJRFoundation authors
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AJRFractionFormatter;

@interface AJRUnitsFormatter : NSFormatter

/**
 Creates a default formatter configured to accept values in "points" and display them in "inches".
 
 @return The newly created formatter.
 */
- (id)init;

/**
 Returns a formatter configured to accept units in `units` as well as to display value in the given units.
 
 @param units The units for the input value as well as the display units.
 
 @return A newly created formatter.
 */
- (id)initWithUnits:(NSUnit *)units;
/**
 Returns a formatter configured to accept units in `units` and to display those values in `displayUnits` units.
 
 For example, you might commonly pass in `[NSUnitLength points]` as `units` and `[NSUnitLength inches]` as `displayUnits`. This would then display screen "points" measurements in inches.
 
 @param units The units of the input/output values.
 @param displayUnits The units to display the value as. Value may be `nil` if the display units are the same as units.
 */
- (id)initWithUnits:(NSUnit *)units displayUnits:(nullable NSUnit *)displayUnits;

/// The units used to display the value. If set to nil, then `units` are simply returned.
@property (null_resettable,nonatomic,strong) NSUnit *displayUnits;
/// The base units of the value. Basically, when you pass in a value, they're assumed to be in the these units, and returned values will be converted to these units.
@property (nonatomic,strong) NSUnit *units;
/// If the `displayUnits` is set to "inches", then setting this to `YES` will cause the inches to display as fractions.
@property (nonatomic,assign) BOOL displayInchesAsFrations;

/// Returns the underlying number formatter for formatting the values of the measurement. If we're displaying fractions, this will actually be an AJRFractionFormatter. If that's the case, you can access the `fractionFormatter` property to get one that's propertly typed.
@property (nonatomic,readonly) NSNumberFormatter *numberFormatter;
/// If we're displaying fractions, this returns the underlying fraction formatter. Otherwise it returns nil.
@property (nullable,nonatomic,readonly) AJRFractionFormatter *fractionFormatter;

@end

NS_ASSUME_NONNULL_END
