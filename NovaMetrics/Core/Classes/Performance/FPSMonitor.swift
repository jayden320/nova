//
//  FPSMonitor.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/25.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

class FPSMonitor {
    var isRunning = false
    var fps: Int?
    var callback: ((Int) -> Void)?

    private var link: CADisplayLink?
    private var count: Int = 0
    private var lastTime: Double?

    func start() {
        if link == nil {
            link = CADisplayLink(target: self, selector: #selector(trigger(_:)))
            link?.add(to: RunLoop.main, forMode: .common)
        }
    }

    func stop() {
        guard let link = link else {
            return
        }
        link.isPaused = true
        link.invalidate()
        self.link = nil
        lastTime = nil
        count = 0
    }

    @objc func trigger(_ link: CADisplayLink) {
        guard let lastTime = lastTime else {
            lastTime = link.timestamp
            return
        }
        count += 1
        let delta = link.timestamp - lastTime
        if delta < 1 {
            return
        }
        self.lastTime = link.timestamp
        let fps = Double(count) / delta
        count = 0

        let intFps = Int(fps + 0.5)
        self.fps = intFps
        if let callback = callback {
            callback(intFps)
        }
    }
}
