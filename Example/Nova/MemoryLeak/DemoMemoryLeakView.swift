//
//  DemoMemoryLeakView.swift
//  NovaUI_Example
//
//  Created by Jayden Liu on 2022/7/14.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

class DemoMemoryLeakView: UIView {
    var model: DemoMemoryLeakModel
    override init(frame: CGRect) {
        model = DemoMemoryLeakModel()
        super.init(frame: frame)
        accessibilityIdentifier = "leak view"
        backgroundColor = UIColor.orange
        model.closure = { () -> Void in
            self.doSomeThing()
        }
        model.callClosure()
    }

    func doSomeThing() {
        print("view doSomeThing")
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("view deinit")
    }
}
