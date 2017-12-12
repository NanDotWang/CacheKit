//
//  Option.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-29.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Available cache options
public enum Option {
    
    /// Only cache the target in memory, not in disk.
    case cacheInMemoryOnly
    
    /// Force downloading the target from remote resouce, local cache ignored.
    case forceRefresh
}

/// Make Option equatable without considering its associated values
extension Option: Equatable {
    public static func ==(lhs: Option, rhs: Option) -> Bool {
        switch (lhs, rhs) {
        case (.cacheInMemoryOnly, .cacheInMemoryOnly): return true
        case (.forceRefresh, .forceRefresh): return true
        default: return false
        }
    }
}
