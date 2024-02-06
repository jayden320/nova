//
//  IssueNotificationHandler.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/7/7.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import Foundation

class IssueNotificationHandler: NovaDelegate {
    func onReport(_ issue: NovaIssue) {
        DispatchQueue.main.async {
            self.showNotification(issue: issue)
        }
    }
    
    func showNotification(issue: NovaIssue) {
        guard NovaUILauncher.shared.isIssueNotificationEnabled, NovaUILauncher.shared.isNotificationEnable(issue.tag) else {
            return
        }
        let title = issue.name ?? issue.tag
        let desc = issue.clue ?? "An issue was detected, click to see more"
        
        var icon: UIImage?
        if #available(iOS 14.0, *) {
            icon = UIImage(systemName: "ladybug.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        }
        RNNotificationView.show(withImage: icon,
                                title: title,
                                message: desc,
                                duration: 2,
                                iconSize: CGSize(width: 46, height: 46),
                                onTap: {
            if let logPath = issue.logPath {
                let nc = UINavigationController(rootViewController: IssueDetailViewController(title: title, logPath: logPath))
                nc.modalPresentationStyle = .fullScreen
                NovaUILauncher.shared.homeWindow.show(nc)
            }
        })
    }
}
