//
//  UIView+Extension.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

extension UIView {
    func activateSafeAreaLayout(_ targetView: UIView) {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                leftAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.leftAnchor),
                topAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.topAnchor),
                rightAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.rightAnchor),
                bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                leftAnchor.constraint(equalTo: targetView.leftAnchor),
                topAnchor.constraint(equalTo: targetView.topAnchor),
                rightAnchor.constraint(equalTo: targetView.rightAnchor),
                bottomAnchor.constraint(equalTo: targetView.bottomAnchor),
            ])
        }
    }
}
