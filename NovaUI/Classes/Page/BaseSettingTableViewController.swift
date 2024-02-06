//
//  BaseTableViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/12.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import UIKit

class NovaCell: TDBadgedCell {
    var model: CellModel? {
        didSet { update() }
    }

    private let switchView = UISwitch()

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        switchView.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        badgeColor = .red
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryView = nil
        badgeString = ""
        accessoryType = .none
    }

    private func update() {
        guard let model = model else {
            return
        }
        if let switchValue = model.switchValue {
            switchView.isOn = switchValue
            switchView.isEnabled = model.switchEnable
            accessoryView = switchView
        } else {
            badgeString = model.badge > 0 ? String(model.badge) : ""
        }

        selectionStyle = model.onClicked == nil ? .none : .default
        detailTextLabel?.text = model.detail

        accessoryType = .disclosureIndicator
        textLabel?.text = model.title
        if #available(iOS 13.0, *) {
            textLabel?.textColor = .label
        } else {
            textLabel?.textColor = .darkGray
        }
        textLabel?.textAlignment = .left
    }

    @objc func onSwitchValueChanged(_ switchView: UISwitch) {
        guard let model = model, let onSwitchValueChanged = model.onSwitchValueChanged else {
            return
        }
        onSwitchValueChanged(switchView)
    }
}

class ToggleNovaCell: UITableViewCell {
    func update() {
        selectionStyle = .default
        textLabel?.text = NovaLauncher.shared.isEnabled ? "Turn off" : "Turn on"
        textLabel?.textColor = NovaLauncher.shared.isEnabled ? .systemRed : .systemBlue
        textLabel?.textAlignment = .center
    }
}

class BaseSettingTableViewController: UITableViewController {
    var data = [SectionModel]()

    init() {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NovaCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - TableViewDelegate & TableViewDataSource

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].headerTitle
    }

    override func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        return data[section].footerTitle
    }

    override func numberOfSections(in _: UITableView) -> Int {
        data.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].cellModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NovaCell
        cell.model = data[indexPath.section].cellModels[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = data[indexPath.section].cellModels[indexPath.row]
        if let onClicked = model.onClicked {
            onClicked()
        }
    }
}
