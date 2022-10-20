/*
AJRTranslator.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const AJRSharedStringsTableName;
extern NSString * const AJRTanslatorDidChangeLanguageNotification;

@interface AJRTranslator : NSObject

+ (instancetype)translatorForClass:(Class)class;
+ (instancetype)translatorForObject:(id)object;

- (instancetype)initForClass:(Class)class;
- (instancetype)initForClass:(Class)class stringTableNames:(NSArray<NSString *> *)stringTableNames;

- (id)valueForKey:(NSString *)key;
- (id)valueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;

- (void)addAlternateBundle:(NSBundle *)bundle;
- (void)removeAlternateBundle:(NSBundle *)bundle;

- (void)addStringTableName:(NSString *)name;
- (void)removeStringTableName:(NSString *)name;

@end


@interface NSObject (AJRTranslator)

/*! Allows subclasses to create custom translators, on the rare occasions that's necessary. */
+ (AJRTranslator *)createTranslator;

@property (nonatomic,readonly,class) NSArray<NSString *> *translatorTableNames;
@property (nonatomic,readonly,class) AJRTranslator *translator;

/*!
Returns an AJRTranslator for the given class. The AJRTranslator is an object that is key/value coding  compliant and is designed ot simplify the task of getting values out of your various objects strings  files. For a detailed explanation, please see the AJRTranslator class, but the short description is  the follow:

<ol>
   <li>Call -[NSObject translator] to get an AJRTranslator instance.</li>
   <li>Send translator a valueForKey: to get it to look up a key in a string file using the following
       search order:
       <ol>
           <li>Look in object's bundle for <em>class_name</em>.strings</li>
           <li>Look in object's bundle for <em>bundle_name</em>.strings</li>
           <li>Look in AJRTranslator's bundle for Shared.strings</li>
            <li>Fail and return »<em>key</em>«.</li>
       </ol>
   </li>
</ol>

<p>A handy side effect of this is that you can access the desired string in a number of different ways.  For example, the long hand method is [[myObject translator] valueForKey:@"key"], but you could short  circuit this by just doing [myObject valueForKeyPath:@"translator.key"]. Likewise, since value for
key path works, you can also use IB bindings to bind to your translator. For example, with a button,  bind its "title" to "File's Owner" with the "Model Key Path" of "translator.myKey". While doing the  latter to will suffer a slight performance decrease over the former, you'll rarely find that his is  an issue.
*/
@property (nonatomic,readonly) AJRTranslator *translator;
@property (nonatomic,strong) NSString *translationKey;

@property (nonatomic,readonly) AJRTranslator *ajr_translator;

@end

NS_ASSUME_NONNULL_END
