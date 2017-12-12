//
//  Resource.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-29.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Resource protocol defines the characteristics of a remote resource, remote image or files, etc.
public protocol Resource {
    
    /// Download url of the remote resource
    var url: URL { get }
    
    /// Key used to cache the resource
    var cacheKey: String { get }
    
    /// Each resource should provide a function to parse raw Data into a Codable type for cache purpose
    func parse<T: Codable>(_ data: Data, with options: [Option]) -> T?
}
