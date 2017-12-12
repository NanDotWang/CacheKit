//
//  MemoryCacheTests.swift
//  CacheTests
//
//  Created by Nan Wang on 2017-12-01.
//  Copyright © 2017 NanTech. All rights reserved.
//

import XCTest
import CacheKit

final class MemoryCacheTests: XCTestCase {
    
    private var memoryCache: MemoryCache!
    private let memoryConfiguration = MemoryConfiguration(name: "configuration")
    
    override func setUp() {
        super.setUp()
        memoryCache = MemoryCache(configuration: memoryConfiguration)
    }
    
    override func tearDown() {
        super.tearDown()
        memoryCache = nil
    }
    
    func testSetReferenceTypeObject() {
        let key = "key"
        let testClass = TestClass(name: "testClass")
        
        memoryCache.setObject(testClass, for: key)
        let cachedObject: TestClass? = try? memoryCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        XCTAssertEqual(cachedObject?.name, "testClass")
    }
    
    func testSetValueTypeObject() {
        let key = "key"
        let testStruct = TestStruct(name:"testStruct")
        
        memoryCache.setObject(testStruct, for: key)
        let cachedObject: TestStruct? = try? memoryCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        XCTAssertEqual(cachedObject?.name, "testStruct")
    }
    
    func testRemoveData() {
        let key = "key"
        let data = "data".data(using: .utf8)
        
        memoryCache.setObject(data, for: key)
        let cachedObject: Data? = try? memoryCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        memoryCache.removeObject(for: key)
        let object: Data? = try? memoryCache.object(for: key)
        XCTAssertNil(object)
    }
}

