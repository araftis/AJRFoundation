
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
