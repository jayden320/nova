//
//  NovaController.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/4.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

public protocol NovaDelegate {
    func onReport(_ issue: NovaIssue)
}

enum ConfigKey: String {
    case isNovaDisabled = "Nova.isNovaDisabled"
}

public class NovaLauncher {
    /// Get NovaController singleton
    public static let shared = NovaLauncher()

    /// Nova does not output logs by default. If you need to get the log information in the Nova, you need to set the logDelegate and implement the corresponding method.
    public weak var logDelegate: NovaLogDelegate? {
        get { NovaPrinter.shared.delegate }
        set { NovaPrinter.shared.delegate = newValue }
    }

    /// App can judge whether Nova is running according to this property
    public private(set) var isRuning = false

    /// The plugins passed in at `func launch(plugins: [NovaPlugin])` will be saved to this property.
    public private(set) var plugins: [NovaPlugin] = []

    /// A tool to obtain the current state of the device, such as the cpu, memory occupied by app, the current fps, etc.
    public let performanceUtil = PerformanceUtil()

    /// Determine whether the Nova is enable. If set to false, the Nova will not be launched even if `func launch(plugins: [NovaPlugin])` is called.
    public var isEnabled: Bool {
        get {
            !UserDefaults.standard.bool(forKey: ConfigKey.isNovaDisabled.rawValue)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: ConfigKey.isNovaDisabled.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    /// Determine whether the Nova is enable by default.
    public func setIsEnabledByDefault(_ enable: Bool) {
        UserDefaults.standard.register(defaults: [ConfigKey.isNovaDisabled.rawValue: !enable])
    }

    /// Launch Nova with plugins.
    /// - Parameter plugins: Plugins must be subclasses of NovaPlugin.
    public func launch(plugins: [NovaPlugin]) {
        guard isEnabled else {
            WLOG(message: "Nova is disabled")
            return
        }
        if isRuning {
            WLOG(message: "Nova is runing")
            return
        }
        self.plugins = plugins
        for plugin in plugins {
            NovaEngine.shared.add(plugin)
        }
        isRuning = true
        ILOG(message: "Nova launch successfully")
    }

    /// Add Nova listener. For example, when an issue occurs, the `onReport` callback will be called
    /// - Parameter listener: listening instance
    public func addListener(_ listener: NovaDelegate) {
        NovaEngine.shared.addListener(listener)
    }

    /// Remove Nova listener.
    /// - Parameter listener: listening instance
    public func removeListener(_ listener: NovaDelegate) {
        NovaEngine.shared.removeListener(listener)
    }

    /// Nova will not start plugins by default. This method needs to be called to start the plugin. You can also directly call the plugin's star method.
    /// - Parameter tag: The tag of the plugin that needs to be started
    /// - Returns: Whether the plugin is started successfully
    @discardableResult public func startPlugin(_ tag: String) -> Bool {
        NovaEngine.shared.startPlugin(tag)
    }

    /// Stop the plugin. You can call the start method later to start the plugin again
    /// - Parameter tag: The tag of the plugin that needs to be stopped
    public func stopPlugin(_ tag: String) {
        NovaEngine.shared.stopPlugin(tag)
    }

    /// Start all plugins
    public func starPlugins() {
        NovaEngine.shared.startPlugins()
    }

    /// Stop all plugins
    public func stopPlugins() {
        NovaEngine.shared.stopPlugins()
    }

    /// Stop all plugins and clear memory
    public func destroy() {
        NovaEngine.shared.destroy()
        isRuning = false
    }

    /// Get the corresponding plugin instance according to the tag
    /// - Parameter tag: The tag of the plugin
    /// - Returns: Plugin instance
    public func getPlugin(_ tag: String) -> NovaPlugin? {
        NovaEngine.shared.getPlugin(tag: tag)
    }
}
