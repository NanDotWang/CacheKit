//
//  Result.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Result type
public enum Result<T> {
    case value(T)
    case error(Error)
}
