//
//  MemoryLeakMonitorPlugin.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/7.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

public enum MemoryLeakReportStrategy: String {
    case onceADay
    case everyTime
}

public class MemoryLeakMonitorPlugin: NovaPlugin {
    public static let strategyKey = "Nova.memoryLeakStrategy"

    public var reportStrategy: MemoryLeakReportStrategy {
        get {
            if let value = UserDefaults.standard.string(forKey: MemoryLeakMonitorPlugin.strategyKey),
                let strategy = MemoryLeakReportStrategy(rawValue: value) {
                return strategy
            } else {
                #if DEBUG
                    return .everyTime
                #else
                    return .onceADay
                #endif
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: MemoryLeakMonitorPlugin.strategyKey)
            UserDefaults.standard.synchronize()
        }
    }

    private var leakCache = ExpiredCache(name: "memory_leak", expiration: 60 * 60 * 24)

    public func addWhitelist(_ classNames: [String]) {
        NSObject.ml_addClassNames(toWhitelist: classNames)
    }

    @discardableResult public override func start() -> Bool {
        MLeakAdapter.sharedInstance().hookForMemoryLeakDetectionIfNeeded()
        MLeakAdapter.sharedInstance().delegate = self

        return super.start()
    }

    public override func stop() {
        MLeakAdapter.sharedInstance().delegate = nil
        super.stop()
    }

    public override class func getTag() -> String {
        "Memory Leak"
    }

    public override class func description() -> String? {
        "Plugin for detecting memory leaks, based on MLeakFinder."
    }

    public override class func canReportIssue() -> Bool {
        true
    }
}

extension MemoryLeakMonitorPlugin: MLeakReporterDelegate {
    public func onMemoryLeak(_ proxy: MLeakedObjectProxy) {
        guard let viewStack = proxy.viewStack() as? [String] else {
            return
        }
        let stack = viewStack.joined(separator: "\n")
        if reportStrategy == .onceADay {
            let hashValue = String(stack.hash)
            if !leakCache.isExpired(hashValue) {
                return
            }
            leakCache.append(hashValue)
        }
        let pointer = "0x\(String(Int64(truncating: proxy.objectPtr ?? 0), radix: 16))"
        let log = "leaked pointer: \(pointer)\n\n\(stack)"

        let issue = NovaIssue(tag: MemoryLeakMonitorPlugin.getTag(), clue: "\(viewStack.last ?? "Unknow"): \(pointer)", log: log)
        issue.userInfo["viewStack"] = viewStack
        report(issue)
    }
}
