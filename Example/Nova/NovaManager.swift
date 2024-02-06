//
//  NovaManager.swift
//  Nova_Example
//
//  Created by Jayden Liu on 2022/7/19.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import NovaUI
import Foundation

public class NovaManager {
    public static let shared = NovaManager()

    public func launchNova() {
        let plugins = [
            AnrMonitorPlugin(),
            MemoryLeakMonitorPlugin(),
            UIThreadMonitorPlugin(),
            PageMonitorPlugin(),
        ]

        NovaLauncher.shared.logDelegate = self
        NovaLauncher.shared.launch(plugins: plugins)

        for plugin in plugins {
            plugin.start()
        }

        let uiConfig = NovaUIConfig(isIssueLogEnabled: true, isIssueNotificationEnabled: true, isFloatingWindowEnabled: true)
        NovaUILauncher.shared.launch(defaultConfig: uiConfig)
        NovaUILauncher.shared.addPluginSettingDataSource(dataSource: MemoryLeakPluginSettingDataSource(), tag: MemoryLeakMonitorPlugin.getTag())

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForegroundNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackgroundNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}

extension NovaManager: NovaLogDelegate {
    public func shouldLog(level _: NovaLogLevel) -> Bool {
        true
    }

    public func novaLog(level _: NovaLogLevel, module: String, file _: String, function _: String, line _: Int, message: String) {
        print("[Nova][\(module)] \(message)")
    }
}

extension NovaManager: PageMonitorDelegate {
    public func onPageShow(_: PageMonitorPlugin, pageName: String) {
        print("onPageShow \(pageName)")
    }

    public func shouldMonitorPage(_: PageMonitorPlugin, viewController: UIViewController) -> Bool {
        if viewController.presentingViewController != nil {
            let style = viewController.modalPresentationStyle
            // When a view controller of these styles disappears, its prestened view controller does not call `viewDidAppear` method. It will cause fromPage calculation errors.
            // if style == .custom || style == .overFullScreen || style == .popover {
            if style == .popover {
                return false
            }
        }
        return true
    }

    public func onPageReport(_: PageMonitorPlugin, pageName: String, pageCreationTime: PageCreationTime) {
        print("onPageReport \(pageName)  \(pageCreationTime)")
    }
}

extension NovaManager {
    @objc func applicationWillEnterForegroundNotification(_: Notification) {
        NovaLauncher.shared.startPlugin(AnrMonitorPlugin.getTag())
    }

    @objc func applicationDidEnterBackgroundNotification(_: Notification) {
        NovaLauncher.shared.stopPlugin(AnrMonitorPlugin.getTag())
    }
}

class MemoryLeakPluginSettingDataSource: PluginSettingDataSource {
    func cellModels(for viewController: NovaTableViewController) -> [CellModel]? {
        guard let plugin = NovaLauncher.shared.getPlugin(MemoryLeakMonitorPlugin.getTag()) as? MemoryLeakMonitorPlugin else {
            return nil
        }

        return [CellModel(title: "Report Strategy", detail: plugin.reportStrategy == .onceADay ? "Once a Day" : "Every Time", onClicked: { [weak plugin, weak viewController] in
            let alert = UIAlertController(title: "Report Strategy", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Every Time", style: .default, handler: { _ in
                plugin?.reportStrategy = .everyTime
                viewController?.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Once a Day", style: .default, handler: { _ in
                plugin?.reportStrategy = .onceADay
                viewController?.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            viewController?.present(alert, animated: true)
        })]
    }
}
