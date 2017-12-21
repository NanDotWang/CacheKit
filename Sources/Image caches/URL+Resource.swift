//
//  URL+Resource.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import UIKit

/// Make `URL` a `Resource`
extension URL: Resource {
 
    public var url: URL { return self }
    
    public var cacheKey: String { return absoluteString }
    
    public func parse<T>(_ data: Data) -> T? where T : Decodable, T : Encodable {
        guard let image = UIImage(data: data) else { return nil }
        return CodableImage(with: image) as? T
    }
}
