//
//  UITableViewCell+CacheKit.swift
//  Cache
//
//  Created by Nan Wang on 2017-11-30.
//  Copyright © 2017 NanTech. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    /// Extension on UITableViewCell to set image with a resource
    ///
    /// - Parameters:
    ///   - resource: a resource with `url` and `cacheKey`, can be URL or ImageResource.
    ///   - placeholder: a placeholder image to be shown when loading image from cache or network.
    ///   - options: options provided for combinations of Cache behaviours, image processing, etc.
    /// - Note:
    ///   This extension is designed to be used for the default `imageView` on `UITableViewCell`.
    ///   For custom class of `UITableViewCell` or 'UIImageView', use the method on `UIImageView` extension instead.
    public func setImage(with resource: Resource, placeholder: UIImage? = nil, options: [Option] = []) {
        
        // Show placeholder image
        imageView?.image = placeholder
        
        // Store resource cacheKey into tableview cell associated cacheKey
        // To make sure cell is updated with correct image when async task is done.
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
                        self.imageView?.image = codableImage.image
                        // Need to call `setNeedsLayout` on `UITableViewCell` to make cell gets updated when retrieving image task finishes
                        self.setNeedsLayout()
                    }
                }
            case .error(let error) :
                debuggingPrint("\(error.localizedDescription)")
            }
        }
    }
    
    /// Cancel image downloading request associated to the tableview cell
    public func cancelImageDownloading() {
        retrieveCacheTask?.cancel()
    }
    /// Suspend image downloading request associated to the tableview cell
    public func suspendImageDownloading() {
        retrieveCacheTask?.suspend()
    }
    /// Resume image downloading request associated to the tableview cell
    public func resumeImageDownloading() {
        retrieveCacheTask?.resume()
    }
}

/// Associated objects for UITableViewCell
private extension UITableViewCell {
    /// Associated object keys
    struct AssociatedKeys {
        static var cacheKey = "tableViewCell.cacheKey"
        static var retrieveCacheTask = "tableViewCell.retrieveCacheTask"
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
