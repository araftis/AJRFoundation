/*
 AJRExpressionParser.h
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

@class AJRExpression;

@interface AJRExpressionParser : NSObject
{
    NSData            *_input;
    const UTF32Char    *_rawInput;
    NSInteger        _length;
    NSInteger        _position;
    NSMutableArray    *_stack;
    AJRExpression    *_expression;
}

/*!
 @methodgroup Creation
 */

/*!
 Creates a new expression based on the passed in string. When using this method, you cannot supply
 any variable values to the expression. If you need to pass in variable values, please use one of the
 initWithStringFormat: method instead. Note that this method immediately parses and creates a new
 expression. If an error occurs in the syntax of the expression, an exception will be thrown.
 
 <p>This method basically calls initWithStringFormat:arguments: with a NULL argument list.
 
 @param string The expression to parse. The expression may not contain %@ formatters, and encountering
               one will cause an exception to be thrown.
 
 @result A new expression parser.
 */
- (id)initWithString:(NSString *)string;

/*!
 Creates a new expression based on the string format and variables supplied. This method basically
 calls initWithStringFormat:arguments:
 
 @param string The string containing the expression. This string may contain one or more occurences
               of %@, used to indicate a value that will appear in the variable arguments.
 
 @result A new expression parser.
 */
- (id)initWithStringFormat:(NSString *)string, ...;

/*!
 This is the primary, designated initializer. This creates a new expression parser and parses the
 supplied string. The reason the string must be parsed immediately is because the stack arguments
 may not still be on the stack at a later time. Thus, we must consume them immediately.
 
 <p>The string must be a valid expression. In general, expression are valid C expression, although
 the grammar supports a number of alternate operators that can make expressions a bit more readable.
 At the time of writing, the following operators are supported, with their alternatives:
 
 <table>
    <tr> <th>Operator</th> <th>Alternates</th> <th>Type</th>       <th>Discussion</th> </tr>
    <tr> <td>+</td>        <td></td>           <td>Arithmetic</td> <td>Add if both values are numeric. If two strings, concatenate.</td></tr>
    <tr> <td>&&</td>       <td>and, ∧</td>     <td>Logical</td>    <td>True if and only if both a and b are true.</td></tr>
    <tr> <td>||</td>       <td>or, ∨</td>      <td>Logical</td>    <td>True if a not equal to b.</td></tr>
    <tr> <td>xor</td>      <td>xor, ^^, ⊻</td> <td>Logical</td>    <td>Exclusive or, true if (a or b) and (!a or !b).</td></tr>
    <tr> <td>/</td>        <td>÷</td>          <td>Arithmetic</td> <td>Divide two numbers. Dividing by zero throws an exception.</td></tr>
    <tr> <td>==</td>       <td>=</td>          <td>Logical</td>    <td>Test for equality. Note that numbers can be compared to strings, if the string can convert to a number.</td></tr>
    <tr> <td>&gt;</td>     <td>/td>            <td>Logical</td>       <td>Test for left greater than right.</td></tr>
    <tr> <td>&gt;=</td>    <td>≥</td>          <td>Logical</td>    <td>Test for left greater than or equal to right.</td></tr>
    <tr> <td>&lt;</td>     <td>/td>            <td>Logical</td>       <td>Test for left less than right.</td></tr>
    <tr> <td>&lt;=</td>    <td>≤</td>          <td>Logical</td>    <td>Test for left less than or equal to right.</td></tr>
    <tr> <td>*</td>           <td>×/td>           <td>Arithmetic</td> <td>Multiply two numbers.</td></tr>
    <tr> <td>!=</td>       <td>&lt;&gt;, ≠</td><td>Logical</td>    <td>True if a not equal to b.</td></tr>
    <tr> <td>!</td>        <td>¬</td>          <td>Logical</td>    <td>Inverts the truth of a.</td></tr>
    <tr> <td>-</td>        <td></td>           <td>Arithmetic</td> <td>Subtracts b from a.</td></tr>
 </table>
 
 <p><b>Note 1:</b> The value in the Operator column is the preferred token. Thus, if you say parse the
 expression "a ≠ b", the expression would read back as "a != b".
 <br><b>Note 2:</b> For the purposes of logical expression, true is any numeric value != 0. Likewise, true
 is a numeric string not equal to 0, or the strings "true" or "yes".
 
 <p>Expression may also contain subexpression enclosed with parenthesis. Using these can change the 
 order of precedence of the operators. Thus a + b - c != a + (b - c).
 
 <p>Along with literal values, such as numbers and strings, expression may also contain keys. A key
 is any non-quoted literal. For example, myKey would be a valid key. Keys can contain any alpha-numeric
 character, period, and @, but must begin with a alphabetical character. Keys are lazily evaluated
 when you evalute the expression that results from the parser.
 
 <p>Finally, Additonal operators may be present, and they can be added to the run time by other
 frameworks or bundles. This is done by subclasses AJROperator and implementing the relevant methods.
 */
- (id)initWithStringFormat:(NSString *)string arguments:(va_list)arguments;

/*!
 @methodgroup Properties
 */

/*!
 Returns the expression generated by parsing the string supplied in one of the init methods. Note that
 if the init methods throw an exception (and yet you manage to still call this method), the returned
 expression will be nil.
 
 @result The parsed expression.
 */
- (AJRExpression *)expression;

/*!
 @methodgroup Utilities
 */

/*!
 @result Basically returns the result of [[[AJRExpressionParser alloc] initWithString:string] expression].
 */
+ (AJRExpression *)expressionForString:(NSString *)string;

/*!
 @result Basically returns the result of [[[AJRExpressionParser alloc] initWithStringFormat:string arguments:...] expression].
 */
+ (AJRExpression *)expressionForStringFormat:(NSString *)string, ...;

/*!
 @result Basically returns the result of [[[AJRExpressionParser alloc] initWithStringFormat:string arguments:...] expression].
 */
+ (AJRExpression *)expressionForStringFormat:(NSString *)string arguments:(va_list)arguments;

/*!
 @methodgroup Tokens
 
 These methods are used to effect the tokens, as recognized by the parser. Generally, these are used
 to change the chcaracter sets used when recognizing tokens.
 */

/*!
 Adds a literal token to the parser. Generally these will be alphanumeric strings of some sort, but
 may include unicode characters. For the most part, these tokens should avoid using symbols. You can
 think of literals as being constants or keys found in the input stream. As such, they represent
 things like "myKey", "pi", or "π". Finally, note that some operators may also be literals. As such,
 when parsing literals, the parser will take the token and see if it can first be ajrsociated with 
 and operator. If it can, the literal will be treated as such. Otherwise, it's most commongly treated
 as a key path. Examples of literal like operators are "xor", "or", and "and".
 
 <p>Finally, you will not likely need to call this method directly. Instead, it's called for you as
 AJRConstant subclasses are added to the expression system. Likewise, at start up, literals can contain
 the characters "A-Z", "a-z", "0-9", "_", ".", and "@". Literals may start with "A-Z" and "a-z".
 */
+ (void)addLiteralToken:(NSString *)token;

/*!
 Adds an operator token. Unlike literals, operator tokens may include symbols. If the token supplied
 contains literal characters, then addLiteralToken is called instead. Note that operators should
 contain either letter like symbols or symbols, but not both. Thus "+", "-", and "and" would be valid
 operators, but "and+" would not, and would be parsed by the parser as two separate symbols.
 
 <p>You do not normally need to call this method directly. Instead, it's called for you when the
 various AJROperator subclasses are registered with the expression system. Initially, there are no
 valid operator characters, and the final set used will consist entirely of character registered with
 expression system at runtime. Note that this could change over time, so if additional operators are
 added from a loaded bundle, the character set used to recognize operators could change.
 
 <p>As a special note, some characters are flat out special to the parser, due to the nature of how
 it's used. For this reason, operators may not contain the characters "(", ")", "%", "\"", "'", or 
 start with the character ",".
 */
+ (void)addOperatorToken:(NSString *)token;

@end
