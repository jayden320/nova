//
//  Utils.swift
//  Nova
//
//  Created by Jayden Liu on 2022/8/30.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation
import MachO

public class NovaUtil {
    public class func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())

        return date
    }

    public class func backtraceOfCurrentThread() -> String? {
        backtraceOfThread(thread: nil)
    }

    public class func backtraceOfThread(thread: thread_t?) -> String? {
        return nil
    }

    public class func stripForMainThread(_ backtrace: String) -> String {
        if let range = backtrace.range(of: "Thread 1:") {
            return String(backtrace[backtrace.startIndex ..< range.lowerBound])
        }
        return backtrace
    }
}

extension NSObject {
    @discardableResult
    class func swizzleMethodSelector(_ originalSelector: Selector, swizzledSelector: Selector) -> Bool {
        var originalMethod: Method?
        var swizzledMethod: Method?

        originalMethod = class_getInstanceMethod(self, originalSelector)
        swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

        if originalMethod != nil, swizzledMethod != nil {
            if class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
            return true
        }

        return false
    }
}
