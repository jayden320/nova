//
//  FloatingContentView.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/8/15.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import UIKit

class FloatingContentView: UIView {
    let memoryView = FloatingItemView(suffix: "MB")
    let fpsView = FloatingItemView(suffix: "fps")
    let cpuView = FloatingItemView(suffix: "%")

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .black.withAlphaComponent(0.5)

        let stackView = UIStackView(arrangedSubviews: [
            memoryView,
            cpuView,
            fpsView,
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        NovaLauncher.shared.performanceUtil.fpsCallback = { [weak self] fps in
            self?.update(fps: fps)
        }
        update(fps: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
    }

    deinit {
        NovaLauncher.shared.performanceUtil.fpsCallback = nil
    }

    func update(fps: Int?) {
        let performance = NovaLauncher.shared.performanceUtil
        fpsView.titleLabel.text = fps != nil ? String(fps!) : "-1"
        cpuView.titleLabel.text = String(format: "%.1f", performance.cpuUsageForApp())

        let memory = performance.memoryUsage().used / 1024 / 1024
        memoryView.titleLabel.text = String(memory)
    }
}

class FloatingItemView: UIView {
    let titleLabel = UILabel()
    let stackView = UIStackView()

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(suffix: String?) {
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
//            stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .white
        stackView.addArrangedSubview(titleLabel)

        if let suffix = suffix {
            let spacer = UIView()
            spacer.widthAnchor.constraint(equalToConstant: 1).isActive = true
            stackView.addArrangedSubview(spacer)

            let suffixLabel = UILabel()
            suffixLabel.translatesAutoresizingMaskIntoConstraints = false
            suffixLabel.font = .systemFont(ofSize: 7)
            suffixLabel.text = "\(suffix)"
            suffixLabel.textColor = .white
            stackView.addArrangedSubview(suffixLabel)
        }
    }
}
