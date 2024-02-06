//
//  DemoMemoryLeakModel.swift
//  NovaUI_Example
//
//  Created by Jayden Liu on 2022/7/14.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

class DemoMemoryLeakModel: NSObject {
    var closure: (() -> Void)?

    func callClosure() {
        closure?()
    }

    deinit {
        print("model deinit")
    }
}
