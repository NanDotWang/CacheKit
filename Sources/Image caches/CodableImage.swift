//
//  CodableImage.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import UIKit
import Foundation

/// A codable wrapper around UIImage
public struct CodableImage {

    public let image: UIImage

    public init(with image: UIImage) {
        self.image = image
    }
}

extension CodableImage: Codable {

    public enum CodingKeys: String, CodingKey {
        case image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = UIImage(data: data) else {
            throw CodableImageError.decodingFailed
        }
        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        /// TODO:
        /// Should implement a way to differentiate jpeg, png and other formats of images.
        guard let data = UIImagePNGRepresentation(image) else {
            throw CodableImageError.encodingFailed
        }
        try container.encode(data, forKey: CodingKeys.image)
    }
}

/// CodableImage errors
public enum CodableImageError: LocalizedError {
    case decodingFailed
    case encodingFailed

    public var errorDescription: String? {
        switch self {
        case .decodingFailed: return "[CodableImage] Can not decode data into image"
        case .encodingFailed: return "[CodableImage] Can not encode image into data"
        }
    }
}
