//
//  IssueListViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import UIKit

class IssueListViewController: UITableViewController {
    private var data = [SandboxModel]()
    private var pluginType: NovaPlugin.Type
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(title: String, pluginType: NovaPlugin.Type) {
        self.pluginType = pluginType
        super.init(style: .plain)
        self.title = title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 0.6, constant: 0),
        ])
        indicator.startAnimating()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        loadData()
    }

    func loadData() {
        DispatchQueue.global(qos: .default).async {
            let data = LogUtil.loadSandboxModels(directoryName: self.pluginType.getTag())

            DispatchQueue.main.async {
                self.updateData(data)
            }
        }
    }

    func updateData(_ data: [SandboxModel]) {
        self.data = data
        updateIssueCount(data.count)
        tableView.reloadData()

        if !data.isEmpty {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(cleanLog))
        }
        indicator.stopAnimating()
    }

    @objc private func cleanLog() {
        let alert = UIAlertController(title: "Confirm to delete all issue logs?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            try? LogUtil.cleanDirectory(directoryName: self.pluginType.getTag())
            self.updateIssueCount(0)
            self.data = []
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = nil
        }))
        present(alert, animated: true)
    }

    private func updateIssueCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: "\(ConfigKey.issueCountPrefix)\(pluginType.getTag())")
        UserDefaults.standard.synchronize()
    }

    // MARK: - TableViewDelegate & TableViewDataSource

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let model = data[indexPath.row]
        cell.textLabel?.text = model.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.row]
        let detailVC = IssueDetailViewController(title: model.name, logPath: model.path)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
