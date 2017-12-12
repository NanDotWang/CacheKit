//
//  CacheProvider.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Top level cache provider
/// Providing any Codable object from memory <= disk <= internet.
public final class CacheProvider {
    
    /// Shared instance
    public static let shared = CacheProvider()
    
    /// Network service
    private let service: NetworkService
    
    /// Cache for both memory and disk, default is memory only
    private let cache: Cache
    
    /// Initialiser
    public init(with service: NetworkService = NetworkService(), cache: Cache = Cache(name: String(describing: CacheProvider.self))) {
        self.service = service
        self.cache = cache
    }
    
    /// Get cached object for resource with provided options
    /// memory <= disk <= internet
    /// A RetrieveCacheTask is returned for cancellations when necessary
    @discardableResult
    public func object<T: Codable>(for resource: Resource, with options: [Option], completion: @escaping (Result<T>) -> Void) -> RetrieveCacheTask {
        
        let retrieveCacheTask = RetrieveCacheTask()
        
        /// .forceRefresh option -> Ignore any cache in memory or disk, always get object from internet
        guard (!options.contains { $0 == .forceRefresh }) else {
            loadFromNetwork(with: resource, task: retrieveCacheTask, options: options, completion: completion)
            return retrieveCacheTask
        }
        
        /// .cacheInMemoryOnly option -> Don't cache object into disk
        cache.toDisk = !options.contains { $0 == .cacheInMemoryOnly }
        
        /// Try load object from cache, memory or disk
        cache.object(for: resource.cacheKey) { [weak self] (result: Result<T>) in
            guard let `self` = self else { return }
            switch result {
            case .value(let cachedObject):
                completion(.value(cachedObject))
            case .error(_):
                /// Object does not exist in any cache, try to load it from network
                self.loadFromNetwork(with: resource, task: retrieveCacheTask, options: options, completion: completion)
            }
        }
        return retrieveCacheTask
    }
}

/// Private methods
private extension CacheProvider {
    
    /// Load resource from network
    func loadFromNetwork<T: Codable>(with resource: Resource, task: RetrieveCacheTask, options: [Option], completion: @escaping (Result<T>) -> Void) {
        service.load(resource: resource, task: task, options: options) { [weak self] (result: Result<T>) in
            guard let `self` = self else { return }
            switch result {
            case .value(let codable):
                /// Save the object to cache once successfully downloaded from network
                /// So next time this object can be directly returned from cache.
                self.cache.setObject(codable, for: resource.cacheKey) { (error) in
                    guard let error = error else { return }
                    debuggingPrint("⚠️ Failed to cache newly downloaded object with error: \(error.localizedDescription)")
                }
                completion(.value(codable))
            case .error(let error):
                completion(.error(error))
            }
        }
    }
}
