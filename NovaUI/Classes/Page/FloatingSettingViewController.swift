//
//  FloatingSettingViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/12.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

enum FloatingItemType: String {
    case cpu
    case memory
    case fps

    func desc() -> String {
        switch self {
        case .cpu:
            return "CPU"
        case .memory:
            return "Memory"
        case .fps:
            return "FPS"
        }
    }
}

class FloatingSettingViewController: BaseSettingTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Floating Window"
        updateData()
    }

    private func updateData() {
        data = [
            SectionModel(cellModels: [
                CellModel(title: "Floating Window", switchValue: NovaUILauncher.shared.isFloatingWindowEnabled, onSwitchValueChanged: { [weak self] switchView in
                    self?.toggleFloatingViewVisible(switchView.isOn)
                }),
            ]),
        ]

        if NovaUILauncher.shared.isFloatingWindowEnabled {
            data.append(SectionModel(headerTitle: "Floating Items", cellModels: [
                createFloatingItemCellModel(.cpu),
                createFloatingItemCellModel(.memory),
                createFloatingItemCellModel(.fps),
            ]))
        }
    }

    private func toggleFloatingViewVisible(_ isOn: Bool) {
        NovaUILauncher.shared.isFloatingWindowEnabled = isOn
        tableView.beginUpdates()
        if isOn {
            tableView.insertSections(IndexSet(integer: 1), with: .middle)
        } else {
            tableView.deleteSections(IndexSet(integer: 1), with: .top)
        }
        updateData()
        tableView.endUpdates()
    }

    private func createFloatingItemCellModel(_ type: FloatingItemType) -> CellModel {
        CellModel(title: type.desc(), switchValue: NovaUILauncher.shared.isFloatingItemEnable(type), onSwitchValueChanged: { switchView in
            NovaUILauncher.shared.setIsFloatingItemEnable(switchView.isOn, itemType: type)
        })
    }
}
