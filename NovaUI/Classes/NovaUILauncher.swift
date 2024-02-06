//
//  NovaUIController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/7/5.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import Foundation
import UIKit

public protocol NovaTableViewController: UITableViewController {
    func reloadData()
}

public protocol PluginSettingDataSource {
    func cellModels(for viewController: NovaTableViewController) -> [CellModel]?
}

public protocol NovaHomeDataSource {
    func sectionModels() -> [SectionModel]?
}

public struct SectionModel {
    public var headerTitle: String?
    public var footerTitle: String?
    public let cellModels: [CellModel]

    public init(headerTitle: String? = nil, footerTitle: String? = nil, cellModels: [CellModel]) {
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.cellModels = cellModels
    }
}

public struct CellModel {
    public let title: String
    public var detail: String?
    public var badge: Int = 0
    public var switchValue: Bool?
    public var switchEnable: Bool = true
    public var onSwitchValueChanged: ((UISwitch) -> Void)?
    public var onClicked: (() -> Void)?
    var isNovaDisableCell = false

    public init(title: String, switchValue: Bool, switchEnable: Bool = true, onSwitchValueChanged: @escaping ((UISwitch) -> Void)) {
        self.title = title
        self.switchValue = switchValue
        self.switchEnable = switchEnable
        self.onSwitchValueChanged = onSwitchValueChanged
    }

    public init(title: String, badge: Int = 0, detail: String? = nil, onClicked: (() -> Void)?) {
        self.title = title
        self.badge = badge
        self.detail = detail
        self.onClicked = onClicked
    }

    init(isNovaDisableCell: Bool) {
        title = ""
        self.isNovaDisableCell = isNovaDisableCell
    }
}

public struct NovaUIConfig {
    let isIssueLogEnabled: Bool
    let isIssueNotificationEnabled: Bool
    let isFloatingWindowEnabled: Bool

    /// init method
    /// - Parameters:
    ///   - isIssueLogEnabled: If the log is enabled, when an issue occurs, SDK will write the issue log to the local file.
    ///   - isIssueNotificationEnabled: If issue notification is enabled, when an issue occurs, an issue notification will pop up in the App.
    ///   - isFloatingWindowEnabled: If the floating window is enabled, the floating window related to performance indicators (cpu, memory, FPS) will be displayed in the App.
    public init(isIssueLogEnabled: Bool, isIssueNotificationEnabled: Bool, isFloatingWindowEnabled: Bool) {
        self.isIssueLogEnabled = isIssueLogEnabled
        self.isIssueNotificationEnabled = isIssueNotificationEnabled
        self.isFloatingWindowEnabled = isFloatingWindowEnabled
    }
}

public class NovaUILauncher {
    /// Get NovaUI singleton
    public static let shared = NovaUILauncher()
    
    /// The title displayed on the home page.
    public var title = "Nova"
    
    /// Show nova home page. Users can view the issue log and configure the Nova on this page.
    public func showNovaPage() {
        if !homeWindow.isHidden {
            return
        }
        let nc = UINavigationController(rootViewController: HomeViewController())
        nc.modalPresentationStyle = .fullScreen
        homeWindow.show(nc)
    }

    var homeDataSources: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()
    var pluginSettingDataSources = [String: PluginSettingDataSource]()
    var floatingWindow: FloatingWindow?
    lazy var homeWindow: HomeWindow = {
        HomeWindow(frame: UIScreen.main.bounds)
    }()

    var isIssueNotificationEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: ConfigKey.issueNotificationEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKey.issueNotificationEnabled.rawValue)
        }
    }

    var isIssueLogEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: ConfigKey.issueLogEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKey.issueLogEnabled.rawValue)
        }
    }

    var isFloatingWindowEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: ConfigKey.floatingWindowEnabled.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ConfigKey.floatingWindowEnabled.rawValue)
            if newValue {
                showFloatingWindow()
            } else {
                hideFloatingWindow()
            }
        }
    }

    private var logIssueListener: IssueLogHandler?
    private var notificationIssueListener: IssueNotificationHandler?
    private var homeDataSource: NovaHomeDataSource?

    /// Launch NovaUI
    /// - Parameter defaultConfig: Default configuration of NovaUI. If user changes the configuration in the Nova page, it will override the default configuration
    public func launch(defaultConfig: NovaUIConfig) {
        guard NovaLauncher.shared.isEnabled else {
            return
        }
        UserDefaults.standard.register(defaults: [
            ConfigKey.floatingWindowEnabled.rawValue: defaultConfig.isFloatingWindowEnabled,
            ConfigKey.issueNotificationEnabled.rawValue: defaultConfig.isIssueNotificationEnabled,
            ConfigKey.issueLogEnabled.rawValue: defaultConfig.isIssueLogEnabled,
        ])

        notificationIssueListener = IssueNotificationHandler()
        NovaLauncher.shared.addListener(notificationIssueListener!)

        logIssueListener = IssueLogHandler()
        NovaLauncher.shared.addListener(logIssueListener!)

        if isFloatingWindowEnabled {
            showFloatingWindow()
        }
    }

    /// Hide the home window of the Nova
    public func hideHomeWindow() {
        if !homeWindow.isHidden {
            homeWindow.hide()
        }
    }

    /// Add Nova home page table view's data source.
    /// - Parameter dataSource: data source instance
    public func addHomeDataSource(_ dataSource: NovaHomeDataSource) {
        homeDataSources.add(dataSource as AnyObject)
    }

    /// Remove data source.
    /// - Parameter dataSource: data source instance
    public func removeHomeDataSource(_ dataSource: NovaHomeDataSource) {
        homeDataSources.remove(dataSource as AnyObject)
    }

    /// Add Nova plugin setting data source
    /// - Parameters:
    ///   - dataSource: data source instance
    ///   - tag: plugin tag
    public func addPluginSettingDataSource(dataSource: PluginSettingDataSource, tag: String) {
        pluginSettingDataSources[tag] = dataSource
    }

    /// Remove plugin setting data source.
    /// - Parameter tag: plugin tag
    public func removePluginSettingDataSource(tag: String) {
        pluginSettingDataSources.removeValue(forKey: tag)
    }

    /// Reset user settings
    public func resetConfig() {
        UserDefaults.standard.removeObject(forKey: ConfigKey.floatingWindowEnabled.rawValue)
        UserDefaults.standard.removeObject(forKey: ConfigKey.issueNotificationEnabled.rawValue)
        UserDefaults.standard.removeObject(forKey: ConfigKey.issueLogEnabled.rawValue)
    }

    private func showFloatingWindow() {
        NovaLauncher.shared.performanceUtil.startFPSMonitor()

        if floatingWindow == nil {
            floatingWindow = FloatingWindow()
        }
        floatingWindow?.show()
    }

    private func hideFloatingWindow() {
        NovaLauncher.shared.performanceUtil.stopFPSMonitor()

        if let floatingWindow = floatingWindow {
            floatingWindow.hide()
            self.floatingWindow = nil
        }
    }

    private func getConfig(_ type: ConfigKey) -> [String: Bool] {
        UserDefaults.standard.object(forKey: type.rawValue) as? [String: Bool] ?? [String: Bool]()
    }

    private func saveConfig(_ type: ConfigKey, key: String, value: Bool) {
        var config = getConfig(type)
        config[key] = value
        UserDefaults.standard.set(config, forKey: ConfigKey.notification.rawValue)
        UserDefaults.standard.synchronize()
    }

    // MARK: - Notification

    func isNotificationEnable(_ tag: String) -> Bool {
        return getConfig(.notification)[tag] ?? true
    }

    func setIsNotificationEnable(_ value: Bool, tag: String) {
        saveConfig(.notification, key: tag, value: value)
    }

    // MARK: - Floating

    func isFloatingItemEnable(_ itemType: FloatingItemType) -> Bool {
        getConfig(.floatingItem)[itemType.rawValue] ?? true
    }

    func setIsFloatingItemEnable(_ value: Bool, itemType: FloatingItemType) {
        saveConfig(.floatingItem, key: itemType.rawValue, value: value)
    }
}

enum ConfigKey: String {
    case notification = "Nova.notification"
    case floatingItem = "Nova.floatingItem"

    case floatingWindowEnabled = "Nova.floatingWindowEnabled"
    case issueNotificationEnabled = "Nova.issueNotificationEnabled"
    case issueLogEnabled = "Nova.issueLogEnabled"

    case issueCountPrefix = "Nova.issueCountPrefix"
}
