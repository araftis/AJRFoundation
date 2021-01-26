//
//  URL+ExtensionsTests.swift
//  AJRFoundation Tests
//
//  Created by AJ Raftis on 11/5/19.
//

import XCTest

class URL_ExtensionsTests: XCTestCase {

    func testQueries() -> Void {
        var url = URL(string: "http://www.google.com/search")
        var query : [String:String]?
        
        url = url?.appendingQueryValue("en", key: "hl")
        url = url?.appendingQueryValue("meaning of life".replacingOccurrences(of: " ", with: "+"), key: "q")
        
        XCTAssert(url?.description == "http://www.google.com/search?hl=en&q=meaning+of+life")
        
        url = URL(parsableString: "meaning of life")
        XCTAssert(url != nil && url?.host == "www.google.com" && url?.scheme == "https")
        query = url?.queryDictionary
        XCTAssert(query?["hl"] == "en");
        XCTAssert(query?["q"] == "meaning+of+life")

        url = URL(parsableString: "https://www.apple.com/")
        XCTAssert(url != nil && url?.host == "www.apple.com" && url?.scheme == "https")
        
        url = URL(parsableString: "www.yahoo.com")
        XCTAssert(url != nil && url?.host == "www.yahoo.com" && url?.scheme == "https")
        
        url = URL(parsableString: "www.yahoo.com is fine.")
        XCTAssert(url != nil && url?.host == "www.google.com" && url?.scheme == "https")
        
        url = URL(parsableString: "http://this isnt valid/")
        XCTAssert(url == nil, "Value wasn't nil, but: \(url!)")
    }

    func testPathUTI() -> Void {
        var uti = URL(string: "http://www.apple.com/test.png")?.pathUTI
        XCTAssert(uti == "public.png")
        
        uti = URL(string: "http://www.apple.com/test")?.pathUTI
        XCTAssert(uti == nil)
    }


}
