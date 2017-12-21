//
//  UIImageView+CacheKit.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import UIKit

extension UIImageView {

    /// Extension on UIImageView to set image with a resource
    ///
    /// - Parameters:
    ///   - resource: a resource with `url` and `cacheKey`, can be URL or ImageResource.
    ///   - placeholder: a placeholder image to be shown when loading image from cache or network.
    ///   - options: options provided for combinations of Cache behaviours, image processing, etc.
    public func setImage(with resource: Resource, placeholder: UIImage? = nil, options: [Option] = []) {
        // Show placeholder image
        image = placeholder

        // Store resource cacheKey into `UIImageView` associated cacheKey
        // To make sure image view is updated with correct image when async task is done.
        cacheKey = resource.cacheKey

        // Retrieve image from cache provider
        // Cache provider will provide image in this way: memory <= disk <= network
        retrieveCacheTask = CacheManager.shared.object(for: resource, with: options) { [weak self] (result: Result<CodableImage>) in
            guard let `self` = self else { return }
            switch result {
            case .value(let codableImage):
                DispatchQueue.main.async {
                    // Check if associated cacheKey is still the same with resource cacheKey
                    if self.cacheKey == resource.cacheKey {
                        self.image = codableImage.image
                    }
                }
            case .error(let error) :
                debuggingPrint("\(error.localizedDescription)")
            }
        }
    }
    /// Cancel image downloading request associated to the UIImageView
    public func cancelImageDownloading() {
        retrieveCacheTask?.cancel()
    }
    /// Suspend image downloading request associated to the UIImageView
    public func suspendImageDownloading() {
        retrieveCacheTask?.suspend()
    }
    /// Resume image downloading request associated to the UIImageView
    public func resumeImageDownloading() {
        retrieveCacheTask?.resume()
    }
}

/// Associated objects
private extension UIImageView {
    /// Associated object keys
    struct AssociatedKeys {
        static var cacheKey = "UIImageView.cacheKey"
        static var retrieveCacheTask = "UIImageView.retrieveCacheTask"
    }

    /// Associated cache key
    var cacheKey: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.cacheKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cacheKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Associated retrieve cache task used to cancel / suspend / resume task
    var retrieveCacheTask: RetrieveCacheTask? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.retrieveCacheTask) as? RetrieveCacheTask
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.retrieveCacheTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

