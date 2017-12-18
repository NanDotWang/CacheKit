//
//  RetrieveCacheTask.swift
//  Cache
//
//  Created by Nan Wang on 2017-12-02.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Retrieve cache task, used to cancel downloading task
final public class RetrieveCacheTask {
    
    private let dataTask: URLSessionDataTask
    
    init(with dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    
    public func cancel() {
        dataTask.cancel()
    }
    public func suspend() {
        dataTask.suspend()
    }
    public func resume() {
        dataTask.resume()
    }
}
