//
//  PageMonitorPlugin.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/7.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

public class PageMonitorConfig {}

public protocol PageMonitorDelegate: AnyObject {
    func shouldMonitorPage(_ plugin: PageMonitorPlugin, viewController: UIViewController) -> Bool
    func onPageReport(_ plugin: PageMonitorPlugin, pageName: String, pageCreationTime: PageCreationTime)
    func onPageShow(_ plugin: PageMonitorPlugin, pageName: String)
}

public class PageCreationTime {
    public var viewDidLoadTime: Double
    public var viewWillAppearTime: Double?
    public var viewDidAppearTime: Double?

    init(viewDidLoadTime: Double) {
        self.viewDidLoadTime = viewDidLoadTime
    }
}

public class PageMonitorPlugin: NovaPlugin {
    public weak var delegate: PageMonitorDelegate?
    public var pluginConfig: PageMonitorConfig?

    var whitelist: [String] = []

    public func addWhitelist(_ classNames: [String]) {
        whitelist.append(contentsOf: classNames)
    }

    @discardableResult public override func start() -> Bool {
        if pluginConfig == nil {
            pluginConfig = PageMonitorConfig()
        }
        PageTracker.shared.plugin = self
        UIViewController.pmy_swizzleViewControllerLifecycle()

        return super.start()
    }

    public override func stop() {
        PageTracker.shared.plugin = nil
        super.stop()
    }

    public override func destroy() {
        super.destroy()
    }

    public override class func getTag() -> String {
        "Page Monitor"
    }
}
