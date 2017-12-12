//
//  DiskCacheTests.swift
//  CacheTests
//
//  Created by Nan Wang on 2017-12-02.
//  Copyright © 2017 NanTech. All rights reserved.
//

import XCTest
import CacheKit

final class DiskCacheTests: XCTestCase {
    
    private var diskCache: DiskCache!
    private let diskConfiguration = DiskConfiguration(name: "configuration")
    
    override func setUp() {
        super.setUp()
        diskCache = DiskCache(configuration: diskConfiguration)
    }
    
    override func tearDown() {
        super.tearDown()
        diskCache = nil
    }
    
    func testSetReferenceTypeObject() {
        let key = "key"
        let testClass = TestClass(name: "testClass")
        
        try? diskCache.setObject(testClass, for: key)
        let cachedObject: TestClass? = try? diskCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        XCTAssertEqual(cachedObject?.name, "testClass")
    }
    
    func testSetValueTypeObject() {
        let key = "key"
        let testStruct = TestStruct(name:"testStruct")
        
        try? diskCache.setObject(testStruct, for: key)
        let cachedObject: TestStruct? = try? diskCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        XCTAssertEqual(cachedObject?.name, "testStruct")
    }
    
    func testRemoveData() {
        let key = "key"
        let testStruct = TestStruct(name:"testStruct")
        
        try? diskCache.setObject(testStruct, for: key)
        let cachedObject: TestStruct? = try? diskCache.object(for: key)
        XCTAssertNotNil(cachedObject)
        try? diskCache.removeObject(for: key)
        let object: TestStruct? = try? diskCache.object(for: key)
        XCTAssertNil(object)
    }
}

