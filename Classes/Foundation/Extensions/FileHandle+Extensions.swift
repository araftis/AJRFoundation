//
//  FileHandle+Extensions.swift
//  AJRFoundation
//
//  Created by AJ Raftis on 1/1/24.
//

import Foundation

public extension FileHandle {

    convenience init(url: URL, mode: Int32, createIfNecessary createFlag: Bool, permissions: mode_t? = nil) throws {
        try self.init(path: url.path(percentEncoded: false), mode: mode, createIfNecessary: createFlag, permissions: permissions)
    }

    convenience init(forWritingAtURL url: URL, createIfNecessary flag: Bool, permissions: mode_t? = nil) throws {
        try self.init(path: url.path(percentEncoded: false), mode: O_WRONLY, createIfNecessary: flag, permissions: permissions)
    }

    convenience init(forUpdatingAtURL url: URL, createIfNecessary flag: Bool, permissions: mode_t? = nil) throws {
        try self.init(path: url.path(percentEncoded: false), mode: O_RDWR, createIfNecessary: flag, permissions: permissions)
    }

    convenience init(path: String, mode: Int32, createIfNecessary createFlag: Bool, permissions: mode_t? = nil) throws {

        if createFlag {
            if !FileManager.default.fileExists(atPath: path) {
                let mask = AJRGetUMask()
                var finalPermissions : mode_t = 0
                if let permissions {
                    finalPermissions = permissions & ~mask
                } else {
                    finalPermissions = 01777 & ~mask
                }
                if !FileManager.default.createFile(atPath: path, contents: Data(),
                                                   attributes: [FileAttributeKey.posixPermissions: finalPermissions]) {
                    throw NSError(domain: NSPOSIXErrorDomain, errorNumber: errno)
                }
            }
        }

        if ((mode & O_ACCMODE) == O_RDONLY) {
            var file : Int32 = -1
            path.withCString { path in
                file = open(path, mode)
            }
            if file >= 0 {
                self.init(fileDescriptor: file)
            } else {
                throw NSError(domain: NSPOSIXErrorDomain, errorNumber: errno)
            }
        } else if ((mode & O_ACCMODE) == O_WRONLY) {
            var file : Int32 = -1
            path.withCString { path in
                file = open(path, mode)
            }
            if file >= 0 {
                self.init(fileDescriptor: file)
                try truncate(atOffset: 0)
            } else {
                throw NSError(domain: NSPOSIXErrorDomain, errorNumber: errno)
            }
        } else if ((mode & O_ACCMODE) == O_RDWR) {
            var file : Int32 = -1
            path.withCString { path in
                file = open(path, mode)
            }
            if file >= 0 {
                self.init(fileDescriptor: file)
                try seekToEnd()
            } else {
                throw NSError(domain: NSPOSIXErrorDomain, errorNumber: errno)
            }
        } else {
            throw NSError(domain: NSPOSIXErrorDomain, message: "Invalid file mode: \(mode)")
        }
    }

    convenience init(forWritingAtPath path: String, createIfNecessary flag: Bool, permissions: mode_t? = nil) throws {
        try self.init(path: path, mode: O_WRONLY, createIfNecessary: flag, permissions: permissions)
    }

    convenience init(forUpdatingAtPath path: String, createIfNecessary flag: Bool, permissions: mode_t? = nil) throws {
        try self.init(path: path, mode: O_RDWR, createIfNecessary: flag, permissions: permissions)
    }

}
