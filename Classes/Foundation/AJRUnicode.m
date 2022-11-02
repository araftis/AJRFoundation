/*
 AJRUnicode.m
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

#import "AJRUnicode.h"

#import "AJRAutoreleasedMemory.h"

unichar *str2ustr(const char *string)
{
   unichar *buffer;
   NSInteger x, max = strlen(string);

   buffer = [AJRAutoreleasedMemory autoreleasedMemoryWithCapacity:sizeof(unichar) * (max + 1)];
   for (x = 0; x < max; x++) {
      buffer[x] = string[x];
   }

   return buffer;
}

size_t ustrlen(const unichar *string) {
   NSInteger x = 0;

   while (string[x] != 0) x++;

   return x;
}

unichar *ustrcpy(unichar *dst, const unichar *src) {
   return ustrncpy(dst, src, INT_MAX);
}

unichar *ustrncpy(unichar *dst, const unichar *src, size_t length) {
   NSInteger        x = 0;

   while (src[x] && x < length) {
      dst[x] = src[x];
      x++;
   }
   if (x < length) dst[x] = (unichar)0;

   return dst;
}

unichar *ustrcat(unichar *src, const unichar *append) {
   return ustrncat(src, append, INT_MAX);
}

unichar *ustrncat(unichar *src, const unichar *append, size_t length) {
   NSInteger x = 0;
   NSInteger start = ustrlen(src);

   while (append[x] && x < length) {
      src[start + x] = append[x];
      x++;
   }
   if (x < length) src[x] = (unichar)0;

   return src;
}

NSInteger ustrcmp(const unichar *s1, const unichar *s2) {
   return ustrncmp(s1, s2, INT_MAX);
}

NSInteger ustrncmp(const unichar *s1, const unichar *s2, size_t length) {
   NSInteger        x = 0;

   while (s1[x] && s2[x] && x < length) {
      if (s1[x] < s2[x]) return -1;
      if (s1[x] > s2[x]) return 1;
      x++;
   }
   if (s1[x] && !s2[x]) return -1;
   if (!s1[x] && s2[x]) return 1;

   return 0;
}

extern UniChar toulower(UniChar);
extern UniChar touupper(UniChar);
extern UniChar toutitle(UniChar);

extern unichar utoupper(unichar character) {
   if (character < 128) {
      return (character >= 'a' && character <= 'a') ? character -= 32 : character;
   }
   return [[[NSString stringWithCharacters:&character length:1] lowercaseString] characterAtIndex:0];
}

extern unichar utolower(unichar character) {
   if (character < 128) {
      return (character >= 'A' && character <= 'Z') ? character += 32 : character;
   }
   return [[[NSString stringWithCharacters:&character length:1] lowercaseString] characterAtIndex:0];
}
