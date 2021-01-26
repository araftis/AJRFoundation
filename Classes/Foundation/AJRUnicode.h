
#import <Foundation/Foundation.h>

// Some common characters

#define UNICODE_END_OF_TEXT                 0x0003
#define UNICODE_HORIZONTAL_TAB              0x0009
#define UNICODE_CARRIAGE_RETURN             0x000D
#define UNICODE_HORIZONTAL_BACK_TAB         0x0019
#define UNICODE_DELETE_BACK                 0x007F
#define UNICODE_COPYRIGHT                   0x00A9
#define UNICODE_REGISTERED                  0x00AE
#define UNICODE_EN_SPACE                    0x2002
#define UNICODE_EM_SPACE                    0x2003
#define UNICODE_FOUR_PER_EM_SPACE           0x2005
#define UNICODE_EN_DASH                     0x2013
#define UNICODE_EM_DASH                     0x2014
#define UNICODE_LEFT_QUOTATION_MARK         0x2018
#define UNICODE_RIGHT_QUOTATION_MARK        0x2019
#define UNICODE_LEFT_DOUBLE_QUOTATION_MARK  0x201C
#define UNICODE_RIGHT_DOUBLE_QUOTATION_MARK 0x201D
#define UNICODE_BULLET                      0x2022
#define UNICODE_HORIZONTAL_ELLIPSIS         0x2026
#define UNICODE_FRACTION_SLASH              0x2044
#define UNICODE_SERVICEMARK                 0x2120
#define UNICODE_TRADEMARK                   0x2122
#define UNICODE_SHIFT_KEY                   0x21E7
#define UNICODE_COMMAND_KEY                 0x2318
#define UNICODE_OPTION_KEY                  0x2325
#define UNICODE_ELLIPSIS                    0x2026
#define UNICODE_CONTROL_ARROW_UP            0xF700
#define UNICODE_CONTROL_ARROW_DOWN          0xF701
#define UNICODE_CONTROL_ARROW_LEFT          0xF702
#define UNICODE_CONTROL_ARROW_RIGHT         0xF703
#define UNICODE_DELETE                      0xF728
#define UNICODE_OBJECT_REPLACEMENT          0xFFFC

extern unichar *str2ustr(const char *string);
extern size_t ustrlen(const unichar *string);
extern unichar *ustrcpy(unichar *dst, const unichar *src);
extern unichar *ustrncpy(unichar *dst, const unichar *src, size_t length);
extern unichar *ustrcat(unichar *src, const unichar *append);
extern unichar *ustrncat(unichar *src, const unichar *append, size_t length);
extern NSInteger ustrcmp(const unichar *s1, const unichar *s2);
extern NSInteger ustrncmp(const unichar *s1, const unichar *s2, size_t length);

extern unichar utoupper(unichar character);
extern unichar utolower(unichar character);

