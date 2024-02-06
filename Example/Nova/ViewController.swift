//
//  ViewController.swift
//  Nova
//
//  Created by Jayden Liu on 07/18/2022.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import NovaUI
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nova Demo"
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Nova", style: .plain, target: self, action: #selector(showNovaPage))
    }

    @objc func showNovaPage() {
        NovaUILauncher.shared.showNovaPage()
    }

    @IBAction func testANR(_: Any) {
        print("ANR will comming")
        Thread.sleep(forTimeInterval: 6)
        print("ANR did end")
    }

    @IBAction func testPageMonitor(_: Any) {
        navigationController?.pushViewController(ViewController(), animated: true)
    }

    @IBAction func testMemoryLeak(_: Any) {
        navigationController?.pushViewController(DemoMemoryLeakViewController(), animated: true)
    }

    @IBAction func testNonUiThread(_: Any) {
        DispatchQueue.global().async {
            self.view.setNeedsLayout()
        }
    }
}
