//
//  MemoryCache.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Memory cache
final public class MemoryCache {
    
    /// User NSCache as memory cache
    private let cache = NSCache<NSString, MemoryCacheWrapper>()
    
    /// Memory configuration
    private let configuration: MemoryConfiguration
    
    /// Initialiser
    public init(configuration: MemoryConfiguration) {
        self.configuration = configuration
        self.cache.name = configuration.name
        self.cache.countLimit = Int(configuration.countLimit)
        self.cache.totalCostLimit = Int(configuration.maxSize)
    }
    
    /// Store any Codable object into memory cache
    public func setObject<T: Codable>(_ object: T, for key: String) {
        self[key] = MemoryCacheWrapper(with: object)
    }
    
    /// Retrieve any Codable object from memory cache
    public func object<T: Codable>(for key: String) throws -> T {
        guard let memoryCacheWrapper = self[key] else {
            throw MemoryCacheError.notExist
        }
        
        guard let object = memoryCacheWrapper.object as? T else {
            throw MemoryCacheError.unexpectedType
        }
        
        return object
    }
    
    /// Remove object from memory cache
    public func removeObject(for key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }
    
    /// Subscript
    public subscript(key: String) -> MemoryCacheWrapper? {
        get {
            return cache.object(forKey: key as NSString)
        }
        set {
            if let memoryCacheWrapper = newValue {
                cache.setObject(memoryCacheWrapper, forKey: key as NSString)
            } else {
                cache.removeObject(forKey: key as NSString)
            }
        }
    }
}

/// Because `NSCache` can only store `NSObject`,
/// a wrapper is created to be able to store any Codable object, refrence or value type
final public class MemoryCacheWrapper: NSObject {
    
    let object: Codable
    
    init(with object: Codable) {
        self.object = object
    }
}

/// MemoryCache errors
public enum MemoryCacheError: LocalizedError {
    case notExist
    case unexpectedType
    
    public var errorDescription: String? {
        switch self {
        case .notExist: return "[MemoryCache] Object does not exist"
        case .unexpectedType: return "[MemoryCache] Object returned does not match the type of object expected"
        }
    }
}
