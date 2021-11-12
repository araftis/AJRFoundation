/*
UserDefaults+ExtensionsTests.swift
AJRFoundation

Copyright © 2021, AJ Raftis and AJRFoundation authors
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

import XCTest

import AJRFoundation

extension AJRUserDefaultsKey {
    
    static var stringDefault : AJRUserDefaultsKey<String> {
        return AJRUserDefaultsKey<String>.key(named: "stringDefault", defaultValue: "test")
    }
    
    static var intDefault : AJRUserDefaultsKey<Int> {
        return AJRUserDefaultsKey<Int>.key(named: "intDefault")
    }
    
    static var floatDefault : AJRUserDefaultsKey<Float> {
        return AJRUserDefaultsKey<Int>.key(named: "floatDefault", defaultValue: 1.0)
    }
    
    static var doubleDefault : AJRUserDefaultsKey<Double> {
        return AJRUserDefaultsKey<Double>.key(named: "doubleDefault", defaultValue: 1.0)
    }
    
    static var boolDefault : AJRUserDefaultsKey<Bool> {
        return AJRUserDefaultsKey<Bool>.key(named: "boolDefault", defaultValue: false)
    }
    
    static var urlDefault : AJRUserDefaultsKey<URL> {
        return AJRUserDefaultsKey<URL>.key(named: "urlDefault", defaultValue: URL(string: "https://www.apple.com"))
    }
    
    static var dictionaryDefault : AJRUserDefaultsKey<Dictionary<String,String>> {
        return AJRUserDefaultsKey<Dictionary<String,String>>.key(named: "dictionaryDefault", defaultValue: ["one":"uno"])
    }
    
    static var arrayDefault : AJRUserDefaultsKey<Array<String>> {
        return AJRUserDefaultsKey<Array<String>>.key(named: "arrayDefault", defaultValue: ["one", "two"])
    }
    
    static var arrayOfURLsDefault : AJRUserDefaultsKey<Array<URL>> {
        return AJRUserDefaultsKey<Array<String>>.key(named: "arrayOfURLsDefault", defaultValue: [URL(string: "https://www.apple.com")!, URL(string: "https://www.google.com/")!])
    }
    
    static var setDefault : AJRUserDefaultsKey<Set<String>> {
        return AJRUserDefaultsKey<Set<String>>.key(named: "setDefault", defaultValue: ["one", "two"])
    }
    
    static var setOfURLsDefault : AJRUserDefaultsKey<Set<URL>> {
        return AJRUserDefaultsKey<Set<URL>>.key(named: "setOfURLsDefault", defaultValue: [URL(string: "https://www.apple.com")!, URL(string: "https://www.google.com/")!])
    }
    
    static var dataDefault : AJRUserDefaultsKey<Data> {
        return AJRUserDefaultsKey<Data>.key(named: "dataDefault", defaultValue: Data())
    }
    
}

class UserDefaults_ExtensionsTests: XCTestCase {
    
    func testExample() {
        UserDefaults[.stringDefault] = "test 2"
        XCTAssert(UserDefaults[.stringDefault] == "test 2")
        UserDefaults[.stringDefault] = nil
        XCTAssert(UserDefaults[.stringDefault] == "test")
        
        UserDefaults[.intDefault] = 2
        XCTAssert(UserDefaults[.intDefault] == 2)
        UserDefaults[.intDefault] = nil
        XCTAssert(UserDefaults[.intDefault] == nil)
        
        autoreleasepool {
            var observed = false
            var fail = false
            let observerToken = AJRUserDefaultsKey<Int>.addObserver(callInitially: true, to: .intDefault) {
                observed = true
                if fail {
                    let exception = NSException(name: NSExceptionName(rawValue: "Test"), reason: "Testing if we fail", userInfo: nil)
                    exception.raise()
                }
            }
            XCTAssert(observed)
            observed = false
            AJRUserDefaultsKey<Int>.intDefault.value = 2
            XCTAssert(observed)
            observed = false
            XCTAssert(AJRUserDefaultsKey<Int>.intDefault.value == 2)
            AJRUserDefaultsKey<Int>.intDefault.reset()
            XCTAssert(observed)
            XCTAssert(AJRUserDefaultsKey<Int>.intDefault.value == nil)
            let output = OutputStream.toMemory()
            AJRLogSetOutputStream(output, .warning)
            fail = true
            UserDefaults[.intDefault] = 3
            AJRLogSetOutputStream(nil, .warning)
            XCTAssert(output.ajr_dataAsString(using: String.Encoding.utf8.rawValue)?.contains("Testing if we fail") ?? false)
            UserDefaults[.intDefault] = nil
            AJRUserDefaultsKey<Int>.removeObserver(observerToken)
        }

        UserDefaults[.floatDefault] = 2.0
        XCTAssert(UserDefaults[.floatDefault] == 2.0)
        UserDefaults[.floatDefault] = nil
        XCTAssert(UserDefaults[.floatDefault] == 1.0)
        
        UserDefaults[.doubleDefault] = 2.0
        XCTAssert(UserDefaults[.doubleDefault] == 2.0)
        UserDefaults[.doubleDefault] = nil
        XCTAssert(UserDefaults[.doubleDefault] == 1.0)
        
        UserDefaults[.boolDefault] = true
        XCTAssert(UserDefaults[.boolDefault] == true)
        UserDefaults[.boolDefault] = nil
        XCTAssert(UserDefaults[.boolDefault] == false)
        
        UserDefaults[.urlDefault] = URL(string: "https://www.google.com/")
        XCTAssert(UserDefaults[.urlDefault]?.absoluteString == "https://www.google.com/")
        UserDefaults[.urlDefault] = nil
        XCTAssert(UserDefaults[.urlDefault]?.absoluteString == "https://www.apple.com")
        
        UserDefaults[.dictionaryDefault] = ["two":"dos"]
        XCTAssert(UserDefaults[.dictionaryDefault]?["two"] == "dos")
        UserDefaults[.dictionaryDefault] = nil
        XCTAssert(UserDefaults[.dictionaryDefault]?["one"] == "uno")
        
        UserDefaults[.arrayDefault] = ["three", "four"]
        XCTAssert(UserDefaults[.arrayDefault] == ["three", "four"])
        UserDefaults[.arrayDefault] = nil
        XCTAssert(UserDefaults[.arrayDefault] == ["one", "two"])
        
        let testArrayOfURLs = [URL(string: "https://www.yahoo.com/")!, URL(string: "https://www.duckduckgo.com")!]
        UserDefaults[.arrayOfURLsDefault] = testArrayOfURLs
        XCTAssert(UserDefaults[.arrayOfURLsDefault] == testArrayOfURLs)
        UserDefaults[.arrayOfURLsDefault] = nil
        XCTAssert(UserDefaults[.arrayOfURLsDefault] == [URL(string: "https://www.apple.com")!, URL(string: "https://www.google.com/")!])

        UserDefaults[.setDefault] = ["three", "four"]
        XCTAssert(UserDefaults[.setDefault] == ["three", "four"])
        UserDefaults[.setDefault] = nil
        XCTAssert(UserDefaults[.setDefault] == ["one", "two"])
        
        let testSetOfURLs : Set<URL> = [URL(string: "https://www.yahoo.com/")!, URL(string: "https://www.duckduckgo.com")!]
        UserDefaults[.setOfURLsDefault] = testSetOfURLs
        XCTAssert(UserDefaults[.setOfURLsDefault] == testSetOfURLs)
        UserDefaults[.setOfURLsDefault] = nil
        XCTAssert(UserDefaults[.setOfURLsDefault] == [URL(string: "https://www.apple.com")!, URL(string: "https://www.google.com/")!])

        UserDefaults.standard[.dataDefault] = "Alex".data(using: .utf8)
        XCTAssert(UserDefaults.standard[.dataDefault] == "Alex".data(using: .utf8))
        UserDefaults.standard[.dataDefault] = nil
        XCTAssert(UserDefaults.standard[.dataDefault] == Data())
        
        // Try and make sure we can reconstruct URL's from strings...
        UserDefaults.standard.set(["https://www.duckduckgo.com", "https://www.askjeeves.com/"], forKey: "arrayOfURLsDefault")
        XCTAssert(UserDefaults[.arrayOfURLsDefault] == [URL(string: "https://www.duckduckgo.com")!, URL(string: "https://www.askjeeves.com/")!])
        // Now try with an invalid URL thrown into the mix.
        UserDefaults.standard.set(["https://www.duckduckgo.com", "https://www.ask jeeves.com/", 10], forKey: "arrayOfURLsDefault")
        XCTAssert(UserDefaults[.arrayOfURLsDefault] == [URL(string: "https://www.duckduckgo.com")!])
        
        // Try to create some URLs with scoped security.
        if let url = AJRDocumentsDirectoryURL() {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            UserDefaults[.arrayOfURLsDefault] = [url]
            XCTAssert(UserDefaults[.arrayOfURLsDefault] == [url])
        } else {
            XCTAssert(false, "Couldn't find the doument's directory.")
        }
    }

}
