//
//  Cache.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// A Cache interface that manages both memory cache and disk cache
/// * It can be configured to only cache in memory or both memory & disk.
/// - Note:
/// In Disk cache, `JSONEncoder` & `JSONDecoder` are used to serialize any Codable into Data, deserialize data into Codable.
/// If you try to cache top level primitive types(Int, String, Bool, Data, Date, etc) directly into Cache
/// An encoding error will be thown:
///  "Top-level ... encoded as ... JSON fragment."
/// ## Solutions:
/// * You can wrap top level primitive types into array or dictionary,
/// so it can be serilized into a JSON data.
/// * You can use a custom type wrapper:
///    ```
///    struct TypeWrapper<T: Codable>: Codable {
///        enum CodingKeys: String, CodingKey {
///            case object
///        }
///
///        let object: T
///
///        init(object: T) {
///            self.object = object
///        }
///    }
///    ```
final public class Cache {
    
    /// Cache name
    private let name: String
    
    /// Store cached file to disk or not, default is false, only cache to memory
    var toDisk: Bool = false
    
    /// Memory cache
    /// * Use NSCache under the hood, so it is thread safe
    private let memoryCache: MemoryCache
    
    /// Disk cache
    private let diskCache: DiskCache
    
    /// Use dispatch queue for thread safe read / write on disk cache
    /// * Dispatch queues invoke blocks submitted to them serially in FIFO order.
    /// * A queue will only invoke one block at a time.
    private let queue: DispatchQueue
    
    /// Initialiser
    public init(name: String) {
        self.name = name
        self.memoryCache = MemoryCache(configuration: MemoryConfiguration(name: name))
        self.diskCache = DiskCache(configuration: DiskConfiguration(name: name))
        self.queue = DispatchQueue(label: "com.nanTech.cache.queue")
    }
    
    /// Store object into cache
    public func setObject<T: Codable>(_ object: T, for key: String) {
        
        /// Use MD5 hashed key as cache key
        let cacheKey = MD5(key)
        
        /// Save object into memory
        memoryCache.setObject(object, for: cacheKey)
        
        /// Save object into disk if indicated
        if toDisk {
            queue.sync { [weak self] in
                guard let `self` = self else { return }
                do {
                    try self.diskCache.setObject(object, for: cacheKey)
                } catch {
                    debuggingPrint("⚠️ Failed to cache newly downloaded object with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Get object from cache
    public func object<T: Codable>(for key: String) -> T? {
        
        /// Use MD5 hashed key as cache key
        let cacheKey = MD5(key)
        
        /// Get object from memory cache first
        if let object: T = try? memoryCache.object(for: cacheKey) {
            debuggingPrint("😼 from memory")
            return object
        }
        
        /// Get object from disk cache
        var object: T? = nil
        queue.sync { [weak self] in
            guard let `self` = self else { return }
            object = try? self.diskCache.object(for: cacheKey)
        }
        
        if object != nil {
            /// If object exists in disk but not memory
            /// after retrieving it from disk, store it in memory cache
            /// so next time this object can be retrieved from memory cache directly.
            memoryCache.setObject(object, for: cacheKey)
            debuggingPrint("📀 from disk")
            return object
        }

        debuggingPrint("⚠️ object does not exist in memory, nor disk")
        return object
    }
    
    /// Remove object from cache
    public func removeObject(for key: String, completion: @escaping (Error?) -> Void) {
        let cacheKey = MD5(key)
        memoryCache.removeObject(for: cacheKey)
        queue.async { [weak self] in
            guard let `self` = self else { return }
            do {
                try self.diskCache.removeObject(for: cacheKey)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
