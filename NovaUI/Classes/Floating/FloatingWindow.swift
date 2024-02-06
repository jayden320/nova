//
//  FloatingWindow.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/15.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import UIKit

class FloatingWindow: UIWindow {
    private let floatingWidth: CGFloat = 40.0

    init() {
        let frame = CGRect(x: 0, y: 0, width: floatingWidth, height: floatingWidth)
        super.init(frame: frame)

        windowLevel = .statusBar - 0.01
        if #available(iOS 13.0, *) {
            windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        backgroundColor = .clear
        layer.masksToBounds = true
        rootViewController = UIViewController()

        center = getStartingPosition()

        let contentView = FloatingContentView(frame: frame)
        rootViewController?.view.addSubview(contentView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(autoDocking))
        addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showNovaView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeKey: Bool {
        return false
    }

    func show() {
        isHidden = false
    }

    func hide() {
        isHidden = true
    }

    @objc private func showNovaView() {
        if NovaUILauncher.shared.homeWindow.isHidden {
            NovaUILauncher.shared.showNovaPage()
        }
    }

    @objc private func autoDocking(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let panView = panGestureRecognizer.view else {
            return
        }
        switch panGestureRecognizer.state {
        case .began, .changed:
            let translation = panGestureRecognizer.translation(in: panView)
            panGestureRecognizer.setTranslation(.zero, in: panView)
            panView.center = CGPoint(x: panView.center.x + translation.x, y: panView.center.y + translation.y)
        case .ended, .cancelled:
            let location = panView.center
            var centerX: CGFloat
            var safeBottom = 0.0
            if #available(iOS 11.0, *) {
                safeBottom = safeAreaInsets.bottom
            }
            let centerY = CGFloat(max(min(location.y, UIScreen.appBounds.maxY - safeBottom), UIApplication.shared.statusBarFrame.size.height))
            if location.x > UIScreen.appBounds.width / 2.0 {
                centerX = UIScreen.appBounds.width - floatingWidth / 2
            } else {
                centerX = floatingWidth / 2
            }
            UserDefaults.standard.set(["x": centerX, "y": centerY], forKey: "NovaFloatingPosition")
            UserDefaults.standard.synchronize()

            UIView.animate(withDuration: 0.3, animations: {
                panView.center = CGPoint(x: centerX, y: centerY)
            })
        default:
            break
        }
    }

    private func getStartingPosition() -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
        if let floatingPosition = UserDefaults.standard.object(forKey: "NovaFloatingPosition") as? [String: CGFloat], let x = floatingPosition["x"], let y = floatingPosition["y"] {
            if x < screenSize.width, y < screenSize.height {
                return CGPoint(x: x, y: y)
            }
        }
        return CGPoint(x: floatingWidth / 2, y: screenSize.height / 3)
    }
}
