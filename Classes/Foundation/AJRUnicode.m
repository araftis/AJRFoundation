
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
