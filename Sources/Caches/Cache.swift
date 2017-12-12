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
    private var toDisk: Bool = false
    
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
    public func setObject<T: Codable>(_ object: T, for key: String, completion: @escaping (Error?) -> Void) {
        
        /// Use MD5 hashed key as cache key
        let cacheKey = MD5(key)
        
        /// Save object into memory
        memoryCache.setObject(object, for: cacheKey)
        
        /// Save object into disk if indicated
        if toDisk {
            queue.async { [weak self] in
                guard let `self` = self else { return }
                do {
                    try self.diskCache.setObject(object, for: cacheKey)
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }
    
    /// Get object from cache
    public func object<T: Codable>(for key: String, completion: @escaping (Result<T>) -> Void) {
        
        /// Use MD5 hashed key as cache key
        let cacheKey = MD5(key)
        
        do {
            let object: T = try memoryCache.object(for: cacheKey)
            completion(.value(object))
            debuggingPrint("😼 from memory")
        } catch {
            queue.async { [weak self] in
                guard let `self` = self else { return }
                do {
                    let object: T = try self.diskCache.object(for: cacheKey)
                    /// If object exists in disk but not memory
                    /// after retrieving it from disk, store it in memory cache
                    /// so next time this object can be retrieved from memory cache directly.
                    self.memoryCache.setObject(object, for: cacheKey)
                    completion(.value(object))
                    debuggingPrint("📀 from disk")
                } catch {
                    completion(.error(error))
                }
            }
        }
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
