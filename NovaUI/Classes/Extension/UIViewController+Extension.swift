//
//  UIViewController+Utils.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

extension UIViewController {
    func topViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topViewController() ?? tab
        }

        return self
    }

    func closeButtonItem() -> UIBarButtonItem? {
        guard navigationController?.viewControllers.first == self else {
            return nil
        }
        if #available(iOS 13.0, *) {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.addTarget(self, action: #selector(close), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 10)
            return UIBarButtonItem(customView: button)
        } else {
            return UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        }
    }

    @objc func close() {
        NovaUILauncher.shared.hideHomeWindow()
    }
}
