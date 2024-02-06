//
//  PageTracker.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/20.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

class PageTracker: NSObject, VCProfilerDelegate {
    public static let shared = PageTracker()

    weak var plugin: PageMonitorPlugin?

    var trackingMap = [String: PageCreationTime]()

    var ignoreTypeList = [
        UINavigationController.self,
        UITabBarController.self,
        UIAlertController.self,
        UIActivityViewController.self,
    ]

    override init() {
        super.init()
        VCProfilerAdapter.shared().delegate = self
    }

    func trackViewDidLoad(_ viewController: UIViewController) {
        guard shouldTrack(viewController) else {
            return
        }
        trackingMap[String(format: "%p", viewController)] = PageCreationTime(viewDidLoadTime: CACurrentMediaTime())
    }

    func trackViewWillAppear(_ viewController: UIViewController) {
        if let pageCreationTime = trackingMap[String(format: "%p", viewController)] {
            pageCreationTime.viewWillAppearTime = CACurrentMediaTime()
        }
    }

    func trackViewDidAppear(_ viewController: UIViewController) {
        guard let plugin = plugin, shouldTrack(viewController) else {
            return
        }
        let ref = String(format: "%p", viewController)
        let pageCreationTime = trackingMap.removeValue(forKey: ref)

        guard shouldMonitorPage(viewController) else {
            return
        }

        let pageName = NSStringFromClass(viewController.classForCoder)
        plugin.delegate?.onPageShow(plugin, pageName: pageName)

        if let pageCreationTime = pageCreationTime {
            pageCreationTime.viewDidAppearTime = CACurrentMediaTime()
            if !plugin.whitelist.contains(pageName) {
                plugin.delegate?.onPageReport(plugin, pageName: pageName, pageCreationTime: pageCreationTime)
            }
            DLOG(module: PageMonitorPlugin.getTag(), message: "Finish track \(pageName)  duration: \(pageCreationTime.viewDidAppearTime! - pageCreationTime.viewDidLoadTime)")
        }
    }

    private func shouldTrack(_ viewController: UIViewController) -> Bool {
        for type in ignoreTypeList {
            if viewController.isKind(of: type) {
                return false
            }
        }
        if viewController.isMember(of: UIViewController.self) {
            return false
        }

        return true
    }

    private func shouldMonitorPage(_ viewController: UIViewController) -> Bool {
        if let parent = viewController.parent {
            if !parent.isKind(of: UINavigationController.self) {
                return false
            }
        } else if viewController.presentingViewController == nil {
            return false
        }

        if let plugin = plugin {
            if plugin.delegate?.shouldMonitorPage(plugin, viewController: viewController) == false {
                return false
            }
        }

        return true
    }
}
