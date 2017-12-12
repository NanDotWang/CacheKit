//
//  MemoryConfiguration.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Memory cache configurations
public struct MemoryConfiguration {
    
    /// Memory cache name
    public let name: String
    
    /// Maximum size of memory cache before trying to clean up
    public let maxSize: UInt
    
    /// Count limit
    public let countLimit: UInt
    
    /// Initialiser
    public init(name:String, countLimit: UInt = 100, maxSize: UInt = 10 * 1024 * 1024) {
        self.name = "com.nanTech.memoryCache.\(name)"
        self.countLimit = countLimit
        self.maxSize = maxSize
    }
}
