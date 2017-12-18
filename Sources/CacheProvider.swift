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
    public func object<T: Codable>(for resource: Resource, with options: [Option], completion: @escaping (Result<T>) -> Void) -> RetrieveCacheTask? {
        
        /// .forceRefresh option -> Ignore any cache in memory or disk, always get object from internet
        guard (!options.contains { $0 == .forceRefresh }) else {
            return loadFromNetwork(with: resource, completion: completion)
        }
        
        /// .cacheInMemoryOnly option -> Don't cache object into disk
        cache.toDisk = !options.contains { $0 == .cacheInMemoryOnly }
        
        /// Try load object from cache, memory or disk
        guard let object: T = cache.object(for: resource.cacheKey) else {
            return loadFromNetwork(with: resource, completion: completion)
        }
        
        completion(.value(object))
        return nil
    }
}

/// Private methods
private extension CacheProvider {
    
    /// Load resource from network
    func loadFromNetwork<T: Codable>(with resource: Resource, completion: @escaping (Result<T>) -> Void) -> RetrieveCacheTask {
        return service.load(resource: resource) { [weak self] (result: Result<T>) in
            guard let `self` = self else { return }
            switch result {
            case .value(let codable):
                /// Save the object to cache once successfully downloaded from network
                /// So next time this object can be directly returned from cache.
                self.cache.setObject(codable, for: resource.cacheKey)
                completion(.value(codable))
            case .error(let error):
                completion(.error(error))
            }
        }
    }
}
