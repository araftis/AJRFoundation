//
//  NSFileWrapper+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 10/5/21.
//

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
}

public extension FileWrapper {

    subscript(_ name: String) -> FileWrapper? {
        return fileWrapper(named: name)
    }
    
}
