//
//  DemoMemoryLeakViewController.swift
//  NovaUI_Example
//
//  Created by Jayden Liu on 2022/7/14.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import UIKit

class DemoMemoryLeakViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        let leakView = DemoMemoryLeakView(frame: CGRect(x: 100, y: 200, width: 100, height: 200))
        view.addSubview(leakView)
    }

    deinit {
        print("vc deinit")
    }
}
