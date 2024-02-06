//
//  UIApplication+Utils.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        return base?.topViewController()
    }
}
