//
//  NotificationSettingViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/12.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import UIKit

class NotificationSettingViewController: BaseSettingTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Issue Notification"
        updateData()
    }

    private func updateData() {
        data = [
            SectionModel(cellModels: [
                CellModel(title: "Issue Notification", switchValue: NovaUILauncher.shared.isIssueNotificationEnabled, onSwitchValueChanged: { [weak self] switchView in
                    self?.toggleNotificationEnabled(switchView.isOn)
                }),
            ]),
        ]

        if NovaUILauncher.shared.isIssueNotificationEnabled {
            var cellModels: [CellModel] = []
            for plugin in NovaLauncher.shared.plugins {
                cellModels.append(createCellModel(type(of: plugin)))
            }
            data.append(SectionModel(headerTitle: "Plugins", cellModels: cellModels))
        }
    }

    private func toggleNotificationEnabled(_ isOn: Bool) {
        NovaUILauncher.shared.isIssueNotificationEnabled = isOn
        tableView.beginUpdates()
        if isOn {
            tableView.insertSections(IndexSet(integer: 1), with: .middle)
        } else {
            tableView.deleteSections(IndexSet(integer: 1), with: .top)
        }
        updateData()
        tableView.endUpdates()
    }

    private func createCellModel(_ pluginType: NovaPlugin.Type) -> CellModel {
        let tag = pluginType.getTag()
        return CellModel(title: pluginType.getTag(), switchValue: NovaUILauncher.shared.isNotificationEnable(tag), onSwitchValueChanged: { switchView in
            NovaUILauncher.shared.setIsNotificationEnable(switchView.isOn, tag: tag)
        })
    }
}
