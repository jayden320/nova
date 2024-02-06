//
//  UIScreen+Utils.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

extension UIScreen {
    static var appBounds: CGRect {
        if let window = UIApplication.shared.windows.first {
            return window.bounds
        } else {
            return UIScreen.main.bounds
        }
    }
}
