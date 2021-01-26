//
//  AJRWebSearchProvider.swift
//  AJRMiniBrowser
//
//  Created by AJ Raftis on 2/22/19.
//

import Cocoa

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
