//
//  DiskCache.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Disk cache
final public class DiskCache {
    
    /// File manager
    private let fileManager: FileManager
    
    /// Disk configuration
    private let configuration: DiskConfiguration
    
    /// Full path of disk cache
    private lazy var fullPath: String = {
        guard let directory = self.configuration.directory else {
            preconditionFailure("⚠️ Invalid directory to store disk cache")
        }
        let path = directory.appendingPathComponent(self.configuration.name, isDirectory: true).path
        return path
    }()
    
    public init(configuration: DiskConfiguration, fileManager: FileManager = .default) {
        self.configuration = configuration
        self.fileManager = fileManager
        
        /// Create cache file if not existed
        guard !fileManager.fileExists(atPath: self.fullPath) else { return }
        
        do {
            try fileManager.createDirectory(atPath: self.fullPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            preconditionFailure("⚠️ Unable to create directory for filepath: \(self.fullPath)")
        }
    }
    
    /// Store any Codable object into disk
    public func setObject<T: Codable>(_ object: T, for key: String) throws {
        let data = try encode(object)
        let path = filePath(for: key)
        let fileCreated = fileManager.createFile(atPath: path, contents: data, attributes: nil)
        if !fileCreated {
            throw DiskCacheError.cannotCreateFileAt(path)
        }
    }
    
    /// Retrieve any Codable object from disk
    public func object<T: Codable>(for key: String) throws -> T {
        let path = filePath(for: key)
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let object: T = try decode(from: data)
        return object
    }
    
    /// Remove object from disk
    public func removeObject(for key: String) throws {
        try fileManager.removeItem(atPath: filePath(for: key))
    }
}

/// Private methods
private extension DiskCache {
    
    /// Get file path for specific key
    func filePath(for key: String) -> String {
        return fullPath + "/" + key
    }
}

/// DiskCache errors
public enum DiskCacheError: LocalizedError {
    case cannotCreateFileAt(String)
    
    public var errorDescription: String? {
        switch self {
        case .cannotCreateFileAt(let path): return "[DiskCache] Can not create file at path: \(path)"
        }
    }
}
