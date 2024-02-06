//
//  HomeWindow.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/24.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

class HomeWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = .statusBar - 0.05
        if #available(iOS 13.0, *) {
            windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        rootViewController = UIViewController()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(_ viewController: UIViewController) {
        makeKeyAndVisible()
        rootViewController?.present(viewController, animated: true)
    }

    func hide() {
        rootViewController?.dismiss(animated: true, completion: {
            self.isHidden = true
        })
    }
}
