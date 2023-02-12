/*
 AJRWebSearchProvider.swift
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

import Foundation

@objcMembers
public class AJRWebSearchProvider : NSObject {
    
    var displayName: String { return "" }
    var identifier: String { return "" }
    
    private static var _searchProviders = [String:AJRWebSearchProvider]()
    internal class var searchProviders : [String: AJRWebSearchProvider] {
        get {
            if _searchProviders.count == 0 {
                
            }
            return _searchProviders
        }
    }

    public class func registerSearchProvider(providerClass: AJRWebSearchProvider.Type) -> Void {
        let provider = providerClass.init()
        _searchProviders[provider.identifier] = provider
    }
    
    public class func searchProvider(forIdentifier identifier: String) -> AJRWebSearchProvider? {
        return _searchProviders[identifier];
    }
    
    required public override init() {
    }
    
    open func buildSearchURL(for searchTerms: String) -> URL? {
        preconditionFailure("Subclasses must override \(#function)")
    }

}

@objcMembers
public class AJRWebSearchProviderGoogle : AJRWebSearchProvider {
    
    public override var displayName: String { return "Google" }
    public override var identifier: String { return "com.google.www" }
    
    open override func buildSearchURL(for searchTerms: String) -> URL? {
        let url = URL(string: "https://www.google.com/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let string = searchTerms.replacingOccurrences(of: " ", with: "+")
        components.queryItems = [
            URLQueryItem(name:"hl", value:"en"),
            URLQueryItem(name:"q", value:string),
        ]
        return components.url
    }
    
}

@objcMembers
public class AJRWebSearchProviderBing : AJRWebSearchProvider {
    
    public override var displayName: String { return "Bing" }
    public override var identifier: String { return "com.bing.www" }
    
    open override func buildSearchURL(for searchTerms: String) -> URL? {
        let url = URL(string: "https://www.bing.com/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let string = searchTerms.replacingOccurrences(of: " ", with: "+").lowercased()
        components.queryItems = [
            URLQueryItem(name:"q", value:string),
        ]
        return components.url
    }

}

@objcMembers
public class AJRWebSearchProviderYahoo : AJRWebSearchProvider {
    
    public override var displayName: String { return "Yahoo" }
    public override var identifier: String { return "com.yahoo.www" }
    
    open override func buildSearchURL(for searchTerms: String) -> URL? {
        let url = URL(string: "https://www.yahoo.com/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let string = searchTerms.replacingOccurrences(of: " ", with: "+").lowercased()
        components.queryItems = [
            URLQueryItem(name:"p", value:string),
        ]
        return components.url
    }

}

@objcMembers
public class AJRWebSearchProviderDuckDuckGo : AJRWebSearchProvider {
    
    public override var displayName: String { return "DuckDuckGo" }
    public override var identifier: String { return "com.duckduckgo.www" }
    
    open override func buildSearchURL(for searchTerms: String) -> URL? {
        let url = URL(string: "https://duckduckgo.com/?")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        let string = searchTerms.replacingOccurrences(of: " ", with: "+").lowercased()
        components.queryItems = [
            URLQueryItem(name:"q", value:string),
        ]
        return components.url
    }

}
