//
//  UIThreadTracker.swift
//  Nova
//
//  Created by Jayden Liu on 2022/8/30.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import MachO.dyld

typealias UIThreadTrackerCallBack = (_ thread: String, _ loadAddress: String) -> Void

class UIThreadTracker {
    public static let shared = UIThreadTracker()
    var handler: UIThreadTrackerCallBack?
}

extension UIView {
    static var swizzled = false
    class func swizzleLifeCycleForUIThreadMonitor() {
        if !swizzled {
            swizzled = true
            swizzleMethodSelector(#selector(UIView.setNeedsLayout), swizzledSelector: #selector(UIView.nova_setNeedsLayout))
            swizzleMethodSelector(#selector(UIView.setNeedsDisplay as (UIView) -> () -> Void), swizzledSelector: #selector(UIView.nova_setNeedsDisplay as (UIView) -> () -> Void))
            swizzleMethodSelector(#selector(UIView.setNeedsDisplay(_:)), swizzledSelector: #selector(UIView.nova_setNeedsDisplay(_:)))
        }
    }

    @objc func nova_setNeedsLayout() {
        nova_setNeedsLayout()
        checkUiThread()
    }

    @objc func nova_setNeedsDisplay() {
        nova_setNeedsDisplay()
        checkUiThread()
    }

    @objc func nova_setNeedsDisplay(_ rect: CGRect) {
        nova_setNeedsDisplay(rect)
        checkUiThread()
    }

    func checkUiThread() {
        if !Thread.isMainThread {
            if let thread = NovaUtil.backtraceOfCurrentThread() {
                UIThreadTracker.shared.handler?(thread, loadAddress())
            }
        }
    }

    private func loadAddress() -> String {
        for i in 0 ..< _dyld_image_count() {
            if let header = _dyld_get_image_header(i),
                header.pointee.filetype == MH_EXECUTE {
                return "\(Int(bitPattern: header))"
            }
        }
        return "unknown"
    }
}
