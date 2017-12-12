//
//  DiskConfiguration.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Disk cache configurations
public struct DiskConfiguration {
    
    /// Expiration mode for disk cache
    public enum Expiration {
        case never
        case days(Int)
        
        public var date: Date {
            switch self {
            case .never:
                // Reference: http://lists.apple.com/archives/cocoa-dev/2005/Apr/msg01833.html
                return Date(timeIntervalSince1970: 60 * 60 * 24 * 365 * 68)
            case .days(let numberOfDays):
                return Date().addingTimeInterval(60 * 60 * 24 * Double(numberOfDays))
            }
        }
    }
    
    /// Name of the disk cache, will be used as folder name
    public let name: String
    
    /// Expiration period of disk cache, can be .never or .days(Int)
    public let expiration: Expiration
    
    /// Maximum size of disk cache before trying to clean up
    public let maxSize: UInt
    
    /// Directory to store the disk cache
    public let directory: URL?
    
    /// Default cache directory
    public static let defaultCacheDirectory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    /// Initializer
    public init(name: String,
                expiration: Expiration = .days(7),
                maxSize: UInt = 100 * 1024 * 1024, // 100 M
        directory: URL? = DiskConfiguration.defaultCacheDirectory) {
        self.name = "com.nanTech.diskCache.\(name)"
        self.expiration = expiration
        self.maxSize = maxSize
        self.directory = directory
    }
}
