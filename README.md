#  AJRFoundation

## Overview

This is my basic "Foundation" framework. It includes classes that I've been using since my undergraduate days in Computer Science, so some of the code present was written as far back as about 1991. That being said, a lot of code has been dropped over the years, as many categories (extensions) were provided functionality that's not provided by Apple's own classes. Likewise, some classes have been dropped altogether. 

On the other hand, while most classes have been modernized, some will definitely show their older origins. If one of these classes looks useful to you, feel free to contact me. I can usually find a little time to give an older class a little love and updating.

## Documentation

Many of the classes are documented. Many aren't. If you a class looks useful to you, feel free to contact me if it's not documented, and I can probably add documentation fairly quickly. Every once in a while, I will take time to document a few classes here and there, but a lot of the code was written without documentation, and I just haven't had the time to go back and get everything well documented.

## Contributions

I'm open to other developers contributing code. If you have some bug fixes, documentation, or new classes you'd like to see add, please contact me about doing a pull request.

Generally speaking, as this framework moves into the modern world:

    1. New classes should be written in Swift, but should try to remain compatible with Obj-C.
    2. Obj-C classes should make sure they're friendly with Swift. In other words, use appropriate macros like NS_SWIFT_NAME, NS_ENUM, NS_OPTIONS, etc...
    3. Obj-C classes should use property accessors as much as possible, for both instance and class properties. I update these as I come across them.
    4. Obj-C ivars should not be declared in header files. Some classes will still have this, due to being older code.
    5. Try to avoid using +load. Some of the older classes still make use of this, and there's some use of this that's still 100% required, but generally most of the older uses of +load can be replaced by using the plug system. See AJRPlugInManager for details.
    6. Please try to generally follow the style of the existing code. Namely:
        1. Use descriptive variable names. `x` or `y` is OK for indexes, other variables should have more descriptive name.
        2. Use descriptive method and function names. These names should be descriptive enougth to self document.
        3. Files should indent with 4 spaces. Many files still use tabs. These will eventually get updated.
        4. Variable names should use camel-case.
        5. Private variables should have _ in front, as should Obj-C ivars. This will happen automatically if you use properties.
        6. Terse is not always better. Swift, especially, allows some really terse code. This doesn't necessarily provide any performance boosts, and can make the code difficult to read.
        7. Excessive comments aren't necessary, but are appreciated when working with complicated algorithms. You can see when I had to "think" alot about a piece of code, because it'll have more comments.
        8. Try to use proper header docs, and try to keep it up-to-date.
        9. Do you best to keep code coverage and unit testing as high as possible. Make sure to unit test failure cases.
    7. All files should be encoded with UTF-8, unless there's a good reason to use another encoding.

## Attribution

Unfortunately, given the age of the code, and how some of it was adopted, not all code may be properly attributed. If you see some code, and know it's from an outside soucre, please let me know ASAP, so that I can properly attributed it.

## Authors

The initial implementation was primarily created by AJ Raftis <araftis@calpoly.edu>. Some of the code has been contributed from other authors over the years.

If you contribute in a meaningful way, I'll happily add your name here. If you have contributed in a meaningful way, and I haven't given you credit, let me know, and I'll add your name here as well. Appologies in advance, since some of the code has been added by others, and I don't remember who at this point.

## Platforms

Ideally, AJRFoundation should run on all Apple platforms, but it has not recently been tested on iOS platforms. Most of the code should compile for iOS (including iPhone, iPad, Watch, and TV), but there may be issues.

## Feedback

I'm also open to feedback. If you have questions, please contact me at AJ Raftis <araftis@calpoly.edu>. I'm also open pull requests from 3rd parties.

## Unit Testing

This framework has pretty good unit testing. At one point it was up to over 80%. but it may have dropped a little recently. I hope to get that number back up. I do try to keep unit tests up, but, sadly, I don't always have times to keep up as well as I should.

## External Open Source

**OrderedSet.swift** and **OrderedDictinoary.swift** are Copyright © 2018, Apple, Inc. See their respective headers for details.

## License

I'm releasing this under a BSD license.

```
Copyright (c) 2021, AJ Raftis
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of the AJ Raftis nor the names of its contributors may be 
  used to endorse or promote products derived from this software without 
  specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL AJ Raftis BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

