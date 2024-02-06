//
//  NovaEngine.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/4.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import UIKit

public class NovaIssue {
    public var id: String = NSUUID().uuidString
    public var tag: String
    public var name: String?
    public var clue: String?
    public var log: String?
    public var logPath: String?
    public var userInfo: [AnyHashable: Any] = [:]

    public init(tag: String, name: String? = nil, clue: String? = nil, log: String? = nil, userInfo: [AnyHashable: Any] = [:]) {
        self.tag = tag
        self.name = name
        self.clue = clue
        self.log = log
        self.userInfo = userInfo
    }
}

open class NovaPlugin {
    public init() {}

    @discardableResult open func start() -> Bool {
        true
    }

    open func stop() {}

    open func destroy() {}

    open func report(_ issue: NovaIssue) {
        NovaEngine.shared.report(issue)
    }

    open class func canReportIssue() -> Bool {
        false
    }

    open class func getTag() -> String {
        ELOG(message: "getTag has not been implemented")
        return ""
    }

    open class func description() -> String? {
        nil
    }
}

class NovaEngine {
    static let shared = NovaEngine()
    private(set) var plugins: [String: NovaPlugin] = [:]
    private var listeners: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()

    func add(_ plugin: NovaPlugin) {
        let tag = type(of: plugin).getTag()
        if plugins[tag] == nil {
            plugins[tag] = plugin
        }
    }

    func report(_ issue: NovaIssue) {
        for case let delegate as NovaDelegate in listeners.allObjects {
            delegate.onReport(issue)
        }
    }

    func getPlugin(tag: String) -> NovaPlugin? {
        plugins[tag]
    }

    @discardableResult public func startPlugin(_ tag: String) -> Bool {
        if let plugin = getPlugin(tag: tag) {
            return plugin.start()
        }
        return false
    }

    public func stopPlugin(_ tag: String) {
        if let plugin = getPlugin(tag: tag) {
            plugin.stop()
        }
    }

    func startPlugins() {
        plugins.forEach { (_: String, value: NovaPlugin) in
            value.start()
        }
    }

    func stopPlugins() {
        plugins.forEach { (_: String, value: NovaPlugin) in
            value.stop()
        }
    }

    func destroy() {
        stopPlugins()
        plugins.forEach { (_: String, value: NovaPlugin) in
            value.destroy()
        }
        plugins.removeAll()
        listeners.removeAllObjects()
    }

    func addListener(_ listener: NovaDelegate) {
        listeners.add(listener as AnyObject)
    }

    func removeListener(_ listener: NovaDelegate) {
        listeners.remove(listener as AnyObject)
    }
}
