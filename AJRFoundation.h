/*
 AJRFoundation.h
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

#import <AJRFoundation/AJRFoundationOS.h>

#import <AJRFoundation/AJRActivity.h>
#import <AJRFoundation/AJRAutoreleasedMemory.h>
#import <AJRFoundation/AJRCaseInsensitiveString.h>
#import <AJRFoundation/AJRClassEnumerator.h>
#import <AJRFoundation/AJRCollection.h>
#import <AJRFoundation/AJRConversions.h>
#import <AJRFoundation/AJRDelegateProxy.h>
#import <AJRFoundation/AJREditableObject.h>
#import <AJRFoundation/AJREditingContext.h>
#import <AJRFoundation/AJRFileFinder.h>
#import <AJRFoundation/AJRFileOutputStream.h>
#import <AJRFoundation/AJRFractionFormatter.h>
#import <AJRFoundation/AJRFormat.h>
#import <AJRFoundation/AJRFunctions.h>
#import <AJRFoundation/AJRGate.h>
#import <AJRFoundation/AJRHost.h>
#import <AJRFoundation/AJRHTTPProxy.h>
#import <AJRFoundation/AJRLogging.h>
//#import <AJRFoundation/AJRMain.h>
#import <AJRFoundation/AJRMemoryHandle.h>
#import <AJRFoundation/AJRMethodEnumerator.h>
#import <AJRFoundation/AJRMutableCaseInsensitiveDictionary.h>
#import <AJRFoundation/AJRMutableCountedDictionary.h>
#import <AJRFoundation/AJRMutableOrderedDictionary.h>
#import <AJRFoundation/AJROrderedCompletionQueue.h>
#ifdef AJRFoundation_MacOSX
// Path observation doesn't work on iOS.
#import <AJRFoundation/AJRPathObserver.h>
#endif
#import <AJRFoundation/AJRPlugInAttribute.h>
#import <AJRFoundation/AJRPlugInElement.h>
#import <AJRFoundation/AJRPlugInManager.h>
#import <AJRFoundation/AJRPlugInExtension.h>
#import <AJRFoundation/AJRPlugInExtensionPoint.h>
#import <AJRFoundation/AJRPropertyEnumerator.h>
#import <AJRFoundation/AJRPropertyListCoding.h>
#import <AJRFoundation/AJRProtocolEnumerator.h>
#import <AJRFoundation/AJRProtocolMethodEnumerator.h>
#import <AJRFoundation/AJRProtocolPropertyEnumerator.h>
#import <AJRFoundation/AJRRuntime.h>
#import <AJRFoundation/AJRSemaphores.h>
#import <AJRFoundation/AJRStreamUtilities.h>
#import <AJRFoundation/AJRTimeFormatter.h>
#import <AJRFoundation/AJRTimeIntervalFormatter.h>
#import <AJRFoundation/AJRTranslator.h>
#import <AJRFoundation/AJRUnicode.h>
#import <AJRFoundation/AJRUniqueObject.h>
#import <AJRFoundation/AJRUnitsFormatter.h>
#import <AJRFoundation/AJRVariableEnumerator.h>
#import <AJRFoundation/AJRXMLArchiver.h>
#import <AJRFoundation/AJRXMLCoder.h>
#import <AJRFoundation/AJRXMLCoding.h>
#import <AJRFoundation/AJRXMLUnarchiver.h>
#import <AJRFoundation/AJRXMLOutputStream.h>
#import <AJRFoundation/NSAttributedString+Extensions.h>
#import <AJRFoundation/NSArray+Extensions.h>
#import <AJRFoundation/NSBundle+Extensions.h>
#import <AJRFoundation/NSCharacterSet+Extensions.h>
#import <AJRFoundation/NSCoder+Extensions.h>
#import <AJRFoundation/NSData+Base64.h>
#import <AJRFoundation/NSData+Extensions.h>
#import <AJRFoundation/NSData+UU.h>
#import <AJRFoundation/NSDate+Extensions.h>
#import <AJRFoundation/NSDictionary+Extensions.h>
#import <AJRFoundation/NSError+Extensions.h>
#import <AJRFoundation/NSFileHandle+Extensions.h>
#import <AJRFoundation/NSFileManager+Extensions.h>
#import <AJRFoundation/NSHost+Extensions.h>
#import <AJRFoundation/NSInputStream+Extensions.h>
#import <AJRFoundation/NSKeyedArchiver+Extensions.h>
#import <AJRFoundation/NSKeyedUnarchiver+Extensions.h>
#import <AJRFoundation/NSMutableArray+Extensions.h>
#import <AJRFoundation/NSMutableDictionary+Extensions.h>
#import <AJRFoundation/NSMutableSet+Extensions.h>
#import <AJRFoundation/NSMutableString+Extensions.h>
#import <AJRFoundation/NSMutableURLRequest+Extensions.h>
#import <AJRFoundation/NSNumber+Extensions.h>
#import <AJRFoundation/NSObject+AJRUserInfo.h>
#import <AJRFoundation/NSObject+Extensions.h>
#import <AJRFoundation/NSOutputStream+Extensions.h>
#import <AJRFoundation/NSPointerArray+Extensions.h>
#import <AJRFoundation/NSRunLoop+Extensions.h>
#import <AJRFoundation/NSScanner+Extensions.h>
#import <AJRFoundation/NSSet+Extensions.h>
#import <AJRFoundation/NSString+Extensions.h>
#import <AJRFoundation/NSThread+Extensions.h>
#import <AJRFoundation/NSUnit+Extensions.h>
#import <AJRFoundation/NSURL+Extensions.h>
#import <AJRFoundation/NSURLQueryItem+Extensions.h>
#import <AJRFoundation/NSURLRequest+Extensions.h>
#import <AJRFoundation/NSUserDefaults+Extensions.h>

#if defined(AJRFoundation_MacOSX)
#    import <AJRFoundation/AJRHTTPProxy.h>
#    import <AJRFoundation/AJRPlugInManager.h>
//#    import <AJRFoundation/AJRServer.h>
#    import <AJRFoundation/NSXMLElement+Extensions.h>
#    import <AJRFoundation/NSXMLNode+Extensions.h>
#endif

#if defined(AJRFoundation_iOS)
#    import <CoreGraphics/CoreGraphics.h>
#    import <AJRFoundation/AJRHost.h>
#endif
