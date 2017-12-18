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
