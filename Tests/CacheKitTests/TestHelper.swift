//
//  TestHelper.swift
//  CacheTests
//
//  Created by Nan Wang on 2017-12-01.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

public struct TestStruct: Codable {
    let name: String
}

public final class TestClass: Codable {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

public func image(with color: UIColor = .red, size: CGSize = .init(width: 1, height: 1)) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)

    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image!
}

extension UIImage {
    func isEqualToImage(_ image: UIImage) -> Bool {
        let data = normalizedData()
        return data == image.normalizedData()
    }

    func normalizedData() -> Data {
        let pixelSize = CGSize(
            width : size.width * scale,
            height : size.height * scale
        )

        UIGraphicsBeginImageContext(pixelSize)
        draw(
            in: CGRect(x: 0, y: 0, width: pixelSize.width,
                       height: pixelSize.height)
        )

        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return drawnImage!.cgImage!.dataProvider!.data! as Data
    }
}
