//
//  ImageCache.swift
//  iWeather
//
//  Created by Vamsi Prakhya on 3/30/23.
//

import Foundation
import UIKit.UIImage

final class ImageCache {
    var memoryLimit: Int = 1024*1024*100
    private let lock = NSLock()
    
    init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
    }
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.totalCostLimit = memoryLimit
        return cache
    }()
    
    func insertImage(_ image: UIImage?, for url: String) {
        guard let image = image else { return removeImage(for: url) }
        let decodedImage = image.decodedImage()
        
        lock.lock()
        defer { lock.unlock() }
        imageCache.setObject(image as AnyObject, forKey: url as AnyObject, cost: decodedImage.diskSize)
    }

    func removeImage(for url: String) {
        lock.lock()
        defer { lock.unlock() }
        imageCache.removeObject(forKey: url as AnyObject)
    }
    
    
    public func image(for url: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        
        if let decodedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            return decodedImage
        }
        
        return nil
    }
    
    public func removeAllImages() {
        lock.lock()
        defer { lock.unlock() }
        imageCache.removeAllObjects()
    }

    public subscript(_ key: String) -> UIImage? {
        get {
            return image(for: key)
        }
        set {
            return insertImage(newValue, for: key)
        }
    }
}
