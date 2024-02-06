//
//  IssueLogHandler.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/9.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import Foundation

class IssueLogHandler: NovaDelegate {
    func onReport(_ issue: NovaIssue) {
        guard NovaUILauncher.shared.isIssueLogEnabled else {
            return
        }
        if let path = LogUtil.saveLog(issue.log ?? "", directoryName: issue.tag, fileName: "\(issue.tag) \(NovaUtil.currentDate())") {
            issue.logPath = path
        }
    }
}
