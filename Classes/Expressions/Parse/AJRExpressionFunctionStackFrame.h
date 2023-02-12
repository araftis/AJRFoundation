/*
 AJRExpressionFunctionStackFrame.h
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

#import <AJRFoundation/AJRExpressionStackFrame.h>

@class AJRFunction;

NS_ASSUME_NONNULL_BEGIN

@interface AJRExpressionFunctionStackFrame : AJRExpressionStackFrame 

/*!
 @methodgroup Creation
 */

/*!
 Creates a new, autorelease function stack frame.
 
 @param function The function ajrsociated with the stack frame..
 
 @result A newly allocated stack frame or nil if not enough memory is available.
 */
+ (instancetype)frameWithFunction:(AJRFunction *)function;

/*!
 Initializes a newly creation function stack frame. If name does not map to a valid function, then
 the object is released and an exception is thrown.
 
 @param function The function ajrsociated with the stack frame..
 
 @result A newly initialized stack frame or nil if not enough memory is available.
 */
- (instancetype)initWithFunction:(AJRFunction *)function;

/*!
 @methodgroup Properties
 */

/*!
 The function being tracked by the stack frame. You'll likely not read it directly either. Instead,
 you'll access it indirectly via the stack frame's expression function.
 */
@property (nonatomic,strong,readonly) AJRFunction *function;

/*!
 Called when the parser believes that the stack frame should reduce its current expression into an 
 argument of its ajrsociated function.
 */
- (void)reduceArgument;

@end

NS_ASSUME_NONNULL_END
