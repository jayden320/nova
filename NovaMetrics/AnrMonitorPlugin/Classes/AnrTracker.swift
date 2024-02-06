//
//  AnrTracker.swift
//  Nova
//
//  Created by Jayden Liu on 2022/8/26.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import MachO.dyld

class AnrTracker {
    var thread: AnrMonitorThread?

    deinit {
        stop()
    }

    public func start(threshold: Double, handler: @escaping AnrDetectCallBack) {
        thread = AnrMonitorThread(threshold: threshold, handler: handler)
        thread?.start()
    }

    public func stop() {
        thread?.cancel()
        thread = nil
    }
}

typealias AnrDetectCallBack = (_ info: AnrInfo) -> Void

struct AnrInfo {
    var date: String
    var mainThreadId: mach_port_t
    var threadBacktrace: String
    var loadAddress: String
}

class AnrMonitorThread: Thread {
    private var threshold: Double
    private var handler: AnrDetectCallBack

    private let semaphore = DispatchSemaphore(value: 0)
    private var isMainThreadBlock = false
    var mainThreadId: mach_port_t!

    init(threshold: Double, handler: @escaping AnrDetectCallBack) {
        self.threshold = threshold
        self.handler = handler

        super.init()

        if Thread.isMainThread {
            mainThreadId = mach_thread_self()
        } else {
            DispatchQueue.main.sync {
                mainThreadId = mach_thread_self()
            }
        }
    }

    override func main() {
        DLOG(message: "Anr Detect Thread Start")
        while !isCancelled {
            isMainThreadBlock = true
            DispatchQueue.main.async {
                self.isMainThreadBlock = false
                self.semaphore.signal()
            }
            
            usleep(useconds_t(threshold * 1_000_000))
            if isMainThreadBlock, !isCancelled {
                reportIssue()
            }
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        DLOG(message: "Anr Detect Thread Finish")
    }

    func reportIssue() {
        guard let threadBackTrace = NovaUtil.backtraceOfThread(thread: mainThreadId) else {
            return
        }
        let address = loadAddress()
        let date = NovaUtil.currentDate()
        handler(AnrInfo(date: date, mainThreadId: mainThreadId, threadBacktrace: threadBackTrace, loadAddress: address))
    }

    private func loadAddress() -> String {
        for i in 0 ..< _dyld_image_count() {
            if let header = _dyld_get_image_header(i),
                header.pointee.filetype == MH_EXECUTE {
                return "\(Int(bitPattern: header))"
            }
        }
        return "unknown"
    }
}
