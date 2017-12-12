//
//  NetworkService.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import Foundation

/// Network downloading service
public final class NetworkService {
    
    /// URL session for downloading
    private let session: URLSession
    
    /// Initialiser
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Load resouce from network
    public func load<T: Codable>(resource: Resource, task: RetrieveCacheTask, options: [Option], completion: @escaping (Result<T>) -> Void) {
        
        /// Disable URLCache as we want to have more control of what get cached or not
        /// especially if we add a file cache
        let request = URLRequest(url: resource.url, cachePolicy: .reloadIgnoringLocalCacheData)
        let dataTask = session.dataTask(with: request) { (data, _, error) in
            switch error {
            case .some(let error as NSError) where error.code == NSURLErrorNotConnectedToInternet:
                completion(.error(NetworkServiceError.noInternet))
            case .some(let error):
                completion(.error(NetworkServiceError.other(error)))
            case .none:
                guard let data = data else {
                    completion(.error(NetworkServiceError.noData))
                    return
                }
                guard let codable: T = resource.parse(data, with: options) else {
                    /// There is an invalid url in the response json with `asdf` in it:
                    /// https://s3.amazonaws.com/work-project-image-loading/10284839893_72642asdf63_z.jpg
                    completion(.error(NetworkServiceError.parseDataError))
                    return
                }
                completion(.value(codable))
            }
        }
        dataTask.resume()
        /// Save dataTask for cancellations or other controls
        task.dataTask = dataTask
    }
}

/// NetworkService errors
public enum NetworkServiceError: LocalizedError {
    /// Not connected to internet
    case noInternet
    /// No data returned
    case noData
    /// Can not parse data into a Codable type
    case parseDataError
    /// Other errors
    case other(Error)
}

extension NetworkServiceError {
    
    public var errorDescription: String? {
        switch self {
        case .noInternet: return "[NetworkService] Not connected to internet"
        case .noData: return "[NetworkService] No data"
        case .parseDataError: return "[NetworkService] Can not parse data into a Codable type"
        case .other(let error): return "[NetworkService] \(error.localizedDescription)"
        }
    }
}
