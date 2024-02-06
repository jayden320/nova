//
//  IssueDetailViewController.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/7/6.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

class IssueDetailViewController: UIViewController {
    private let logPath: String
    private let textView = UITextView()

    public init(title: String, logPath: String) {
        self.logPath = logPath
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
        textView.activateSafeAreaLayout(view)
        if FileManager.default.fileExists(atPath: logPath), let log = try? String(contentsOfFile: logPath, encoding: .utf8) {
            textView.text = log
            navigationItem.rightBarButtonItem = moreButtonItem()
        } else {
            textView.text = "File does not exist"
        }
        navigationItem.leftBarButtonItem = closeButtonItem()
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
        let activityVC = UIActivityViewController(activityItems: [URL(fileURLWithPath: logPath)], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}
