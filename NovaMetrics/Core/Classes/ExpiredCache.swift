//
//  ExpiredCache.swift
//  Nova
//
//  Created by Jayden Liu on 2022/9/22.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

class ExpiredCache {
    let name: String
    let expiration: Double

    private lazy var cache: [String: Double] = {
        var cache: [String: Double] = [:]
        guard let url = cacheURL() else {
            return cache
        }
        guard FileManager.default.fileExists(atPath: url.path), let data = NSDictionary(contentsOf: url) as? [String: Double] else {
            return cache
        }
        let now = Date().timeIntervalSince1970
        cache = data.filter { now - $0.value < expiration }
        if cache.keys.count != data.keys.count {
            needSynchronize = true
        }
        return cache
    }()

    private var needSynchronize = false

    init(name: String, expiration: Double) {
        self.name = name
        self.expiration = expiration

        NotificationCenter.default.addObserver(self, selector: #selector(synchronize), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(synchronize), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func append(_ element: String) {
        cache[element] = Date().timeIntervalSince1970

        needSynchronize = true
    }

    func isExpired(_ element: String) -> Bool {
        guard let time = cache[element] else {
            return true
        }
        return Date().timeIntervalSince1970 - time > expiration
    }

    @objc func synchronize() {
        guard needSynchronize, let url = cacheURL() else {
            return
        }
        needSynchronize = false
        NSDictionary(dictionary: cache).write(to: url, atomically: true)
    }

    func cleanCacheFile() throws {
        if let url = cacheURL(), FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(atPath: url.path)
        }
    }

    private func cacheURL() -> URL? {
        guard let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cachePath.appendingPathComponent("nova_cache_\(name).plist")
    }
}
