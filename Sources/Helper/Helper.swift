//
//  Helper.swift
//  Cache
//
//  Created by Nan Wang on 2017-12-02.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Only print in debug mode
public func debuggingPrint(_ object: Any) {
    #if DEBUG
        print(object)
    #endif
}

/// Decode from data into Codable object
public func decode<T: Codable>(from data: Data) throws -> T {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
}

/// Encode Codable object into data
public func encode<T: Codable>(_ object: T) throws -> Data {
    let encoder = JSONEncoder()
    return try encoder.encode(object)
}
