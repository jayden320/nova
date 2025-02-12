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
import UIKit

public class NovaManager {
    public static let shared = NovaManager()
    
    let memoryLeakSettingDataSource = MemoryLeakPluginSettingDataSource()
    
    public func launchNova() {
        let plugins = [
            AnrMonitorPlugin(),
            MemoryLeakMonitorPlugin(),
            UIThreadMonitorPlugin(),
            PageMonitorPlugin(),
        ]

        NovaLauncher.shared.logDelegate = self
        NovaLauncher.shared.launch(plugins: plugins)
        NovaLauncher.shared.addListener(memoryLeakSettingDataSource)

        for plugin in plugins {
            plugin.start()
        }

        let uiConfig = NovaUIConfig(isIssueLogEnabled: true, isIssueNotificationEnabled: true, isFloatingWindowEnabled: true)
        NovaUILauncher.shared.launch(defaultConfig: uiConfig)
        NovaUILauncher.shared.addPluginSettingDataSource(dataSource: memoryLeakSettingDataSource, tag: MemoryLeakMonitorPlugin.getTag())

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

class MemoryLeakPluginSettingDataSource: PluginSettingDataSource, NovaDelegate {
    
    private var leakReports = [LeakReport]()
    
    func cellModels(for viewController: NovaTableViewController) -> [CellModel]? {
        guard let plugin = NovaLauncher.shared.getPlugin(MemoryLeakMonitorPlugin.getTag()) as? MemoryLeakMonitorPlugin else {
            return nil
        }
        
        return [
            CellModel(title: "Report Strategy", detail: plugin.reportStrategy == .onceADay ? "Once a Day" : "Every Time", onClicked: { [weak plugin, weak viewController] in
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
            }),
            
            CellModel(title: "Generate Report", onClicked: { [weak self, weak viewController] in
                self?.generateMemoryLeakReport(viewController: viewController)
            })
        ]
    }
    
    func onReport(_ issue: NovaMetrics.NovaIssue) {
        guard let userInfo = issue.userInfo as? [String: Any],
              let viewStack = userInfo["viewStack"] as? [String] else {
            return
        }
        
        let leakReport = LeakReport(viewStack: viewStack, timestamp: Date(), pageName: viewStack.first ?? "Unknown Page")
        
        leakReports.append(leakReport)
    }
    
    private func generateMemoryLeakReport(viewController: NovaTableViewController?) {
        var reportContent = ""
        for report in leakReports {
            let formattedTime = formatDate(report.timestamp)
            let pageName = report.pageName
            let time = formattedTime
            
            let viewStack = report.viewStack.map { "    \($0)" }.joined(separator: "\n")
            
            reportContent += """
            Time: \(time)
            Page: \(pageName)
            View Stack:
            \(viewStack)
            
            
            """
        }
        
        let reportVC = ReportDetailViewController(title: "Memory Leak", content: reportContent)
        viewController?.present(UINavigationController(rootViewController: reportVC), animated: true)
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

struct LeakReport {
    let viewStack: [String]
    let timestamp: Date
    let pageName: String
}

class ReportDetailViewController: UIViewController {
    private let content: String
    private let textView = UITextView()

    public init(title: String, content: String) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        navigationItem.rightBarButtonItem = moreButtonItem()
        textView.text = content
        navigationItem.leftBarButtonItem = closeButtonItem()
    }
    
    func closeButtonItem() -> UIBarButtonItem? {
        guard navigationController?.viewControllers.first == self else {
            return nil
        }
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
        button.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 10)
        return UIBarButtonItem(customView: button)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.contentOffset = .zero
    }

    private func moreButtonItem() -> UIBarButtonItem {
        if #available(iOS 13.0, *) {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            button.addTarget(self, action: #selector(share), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 0)
            return UIBarButtonItem(customView: button)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        }
    }

    @objc private func share() {
        let activityVC = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}
