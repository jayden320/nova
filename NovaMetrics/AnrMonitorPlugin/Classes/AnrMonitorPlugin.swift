//
//  AnrMonitorPlugin.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/7.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import MachO.dyld

public class AnrMonitorConfig {
    public var threshold: Double = 5.0 // Second

    public init() {}
}

public class AnrMonitorPlugin: NovaPlugin {
    private let anrTracker = AnrTracker()

    public var pluginConfig: AnrMonitorConfig?

    @discardableResult public override func start() -> Bool {
        if pluginConfig == nil {
            pluginConfig = AnrMonitorConfig()
        }
        if let thread = anrTracker.thread, thread.isExecuting {
            DLOG(message: "ANR Already Running")
            return false
        }

        anrTracker.start(threshold: pluginConfig!.threshold) { [weak self] info in
            self?.dump(info)
        }
        return super.start()
    }

    public override func stop() {
        anrTracker.stop()
        super.stop()
    }

    public override func destroy() {
        super.destroy()
    }

    func dump(_ info: AnrInfo) {
        let log = """
        load address: \(info.loadAddress)
        main thread is \(Int(info.mainThreadId))
        """
        let allLog = log + "\n\(info.threadBacktrace)"
        let issue = NovaIssue(tag: AnrMonitorPlugin.getTag(), log: allLog)
        report(issue)
    }

    public override class func getTag() -> String {
        "ANR"
    }

    public override class func description() -> String? {
        "Regularly ping the main thread to detect whether the main thread is blocked."
    }

    public override class func canReportIssue() -> Bool {
        true
    }
}
