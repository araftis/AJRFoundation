/*
 NSFileWrapper+Extensions.swift
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

import Cocoa

@objc public extension FileWrapper {
    
    func fileWrapper(named name: String) -> FileWrapper? {
        return fileWrappers?[name]
    }
    
    @discardableResult func replaceOrAddWrapper(wrapper: FileWrapper) -> String {
        var name = wrapper.preferredFilename
        if name == nil {
            name = wrapper.filename
        }
        if let name = name {
            if let existing = self[name] {
                removeFileWrapper(existing)
            }
        }
        return addFileWrapper(wrapper)
    }
    
    @discardableResult func replaceOrAddRegularFile(withContents data: Data?, preferredFilename name: String) -> String? {
        if let existing = self[name] {
            self.removeFileWrapper(existing)
        }
        if let data = data {
            return addRegularFile(withContents: data, preferredFilename: name)
        }
        return nil
    }

    func contentsAreSame(as other: FileWrapper) -> Bool {
        if isRegularFile && other.isRegularFile {
            // We just going to depend on the modification date, because we don't want to trip and read
            // a bunch of data in to memory, if we don't have to.
            if let modificationDate = fileAttributes["NSFileModificationDate"] as? Date,
               let otherModificationDate = other.fileAttributes["NSFileModificationDate"] as? Date {
                return modificationDate == otherModificationDate
            }
            return false
        } else if isDirectory && other.isDirectory {
            // Safe to force this, since we made sure both are directories.
            var names = Set<String>(fileWrappers!.keys)
            names.formUnion(other.fileWrappers!.keys)
            for name in names {
                if let childWrapper = self[name],
                   let otherChildWrapper = other[name] {
                    if !childWrapper.contentsAreSame(as: otherChildWrapper) {
                        return false
                    }
                } else {
                    // Fail because wrappers had different subwrappers.
                    return false
                }
            }
            // We got through, so we're the same.
            return true
        } else if isSymbolicLink && other.isSymbolicLink {
            return symbolicLinkDestinationURL == other.symbolicLinkDestinationURL
        }
        return false
    }
    
    private static func updateAttributes(on fileWrapper: FileWrapper, from url: URL) -> Void {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            var copy = [String:Any]()
            for (key, value) in attributes {
                copy[key.rawValue] = value
            }
            fileWrapper.fileAttributes = copy
        }
    }
    
    private func privateUpdateFileAttributes(from url: URL) -> Void {
        if self.isRegularFile || self.isSymbolicLink {
            if let filename = filename {
                FileWrapper.updateAttributes(on: self, from: url.appendingPathComponent(filename))
            }
        } else {
            if let children = fileWrappers {
                let fullURL : URL
                if let filename = filename {
                    fullURL = url.appendingPathComponent(filename)
                } else {
                    fullURL = url
                }
                for (_, child) in children {
                    child.updateFileAttributes(from: fullURL)
                }
            }
        }
    }

    func updateFileAttributes(from url: URL) -> Void {
        if self.isRegularFile || self.isSymbolicLink {
            FileWrapper.updateAttributes(on: self, from: url)
        } else {
            if let children = fileWrappers {
                for (_, child) in children {
                    child.privateUpdateFileAttributes(from: url)
                }
            }
        }
    }
    
}

public extension FileWrapper {

    subscript(_ name: String) -> FileWrapper? {
        return fileWrapper(named: name)
    }
    
}
