//
//  HomeViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/7/27.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import UIKit

class HomeViewController: BaseSettingTableViewController, NovaTableViewController {
    var toggleNovaCell = ToggleNovaCell()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NovaUILauncher.shared.title

        navigationItem.leftBarButtonItem = closeButtonItem()
        tableView.register(ToggleNovaCell.self, forCellReuseIdentifier: "ToggleCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    func reloadData() {
        data = []

        if NovaLauncher.shared.isEnabled {
            data.append(SectionModel(headerTitle: "Setting", cellModels: [
                CellModel(title: "Floating Window", switchValue: NovaUILauncher.shared.isFloatingWindowEnabled, onSwitchValueChanged: { switchView in
                    NovaUILauncher.shared.isFloatingWindowEnabled = switchView.isOn
                }),

                CellModel(title: "Issue Notification", switchValue: NovaUILauncher.shared.isIssueNotificationEnabled, onSwitchValueChanged: { [weak self] switchView in
                    NovaUILauncher.shared.isIssueNotificationEnabled = switchView.isOn
                    self?.reloadData()
                }),
            ]))

            for plugin in NovaLauncher.shared.plugins {
                let isVisible = type(of: plugin).canReportIssue()
                if isVisible {
                    data.append(createPluginModels(pluginType: type(of: plugin)))
                }
            }

            for case let homeDataSource as NovaHomeDataSource in NovaUILauncher.shared.homeDataSources.allObjects {
                if let sections = homeDataSource.sectionModels(), !sections.isEmpty {
                    data.append(contentsOf: sections)
                }
            }
        }

        var toggleNovaModel = CellModel(title: "", onClicked: { [weak self] in
            self?.toggleNova()
        })
        toggleNovaModel.isNovaDisableCell = true
        data.append(SectionModel(cellModels: [toggleNovaModel]))

        tableView.reloadData()
    }

    private func toggleNova() {
        NovaLauncher.shared.isEnabled.toggle()
        reloadData()
        showRebootAlert()
    }

    private func showRebootAlert() {
        let alert = UIAlertController(title: "Reboot app to take effect", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    private func createPluginModels(pluginType: NovaPlugin.Type) -> SectionModel {
        let tag = pluginType.getTag()
        let fileCount = LogUtil.loadSandboxModelCount(directoryName: tag)
        let lastFileCount = UserDefaults.standard.integer(forKey: "\(ConfigKey.issueCountPrefix)\(tag)")

        let title = pluginType.getTag()
        var cellModels = [
            CellModel(title: "\(title) Notification", switchValue: NovaUILauncher.shared.isNotificationEnable(tag), switchEnable: NovaUILauncher.shared.isIssueNotificationEnabled, onSwitchValueChanged: { switchView in
                NovaUILauncher.shared.setIsNotificationEnable(switchView.isOn, tag: tag)
            }),
            CellModel(title: "\(title) Logs", badge: fileCount - lastFileCount, onClicked: { [weak self] in
                let vc = IssueListViewController(title: "\(pluginType.getTag()) Logs", pluginType: pluginType)
                self?.navigationController?.pushViewController(vc, animated: true)
            }),
        ]

        if let settingDatSource = NovaUILauncher.shared.pluginSettingDataSources[pluginType.getTag()], let models = settingDatSource.cellModels(for: self) {
            cellModels.append(contentsOf: models)
        }
        return SectionModel(headerTitle: title, footerTitle: pluginType.description(), cellModels: cellModels)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.section].cellModels[indexPath.row] as CellModel
        if model.isNovaDisableCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToggleCell", for: indexPath) as! ToggleNovaCell
            cell.update()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NovaCell
            cell.model = model
            return cell
        }
    }
}
