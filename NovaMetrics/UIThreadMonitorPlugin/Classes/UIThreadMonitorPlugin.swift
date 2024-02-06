//
//  UIThreadMonitorPlugin.swift
//  Nova
//
//  Created by Jayden Liu on 2022/8/12.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import MachO.dyld

public class UIThreadMonitorConfig {
    public init() {}
}

public class UIThreadMonitorPlugin: NovaPlugin {
    public var pluginConfig: UIThreadMonitorConfig?

    @discardableResult public override func start() -> Bool {
        if pluginConfig == nil {
            pluginConfig = UIThreadMonitorConfig()
        }
        UIView.swizzleLifeCycleForUIThreadMonitor()
        UIThreadTracker.shared.handler = { [weak self] thread, loadAddress in
            self?.handleIssue(thread: thread, loadAddress: loadAddress)
        }

        return super.start()
    }

    public override func stop() {
        super.stop()
    }

    public override func destroy() {
        super.destroy()
    }

    func handleIssue(thread: String, loadAddress: String) {
        let log = "load address: \(loadAddress)\n\(thread)"
        let issue = NovaIssue(tag: UIThreadMonitorPlugin.getTag(), name: "UI called on background thread", log: log)
        report(issue)
    }

    public override class func getTag() -> String {
        "UI Thread Monitor"
    }

    public override class func description() -> String? {
        "Detect if UI API is called on a background thread."
    }

    public override class func canReportIssue() -> Bool {
        true
    }
}
