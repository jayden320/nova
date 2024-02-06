//
//  NovaLog.swift
//  Nova
//
//  Created by Jayden Liu on 2022/7/24.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import Foundation

public enum NovaLogLevel {
    case verbose
    case debug
    case info
    case warn
    case error
}

public protocol NovaLogDelegate: AnyObject {
    func shouldLog(level: NovaLogLevel) -> Bool
    func novaLog(level: NovaLogLevel, module: String, file: String, function: String, line: Int, message: String)
}

class NovaPrinter {
    static let shared = NovaPrinter()
    weak var delegate: NovaLogDelegate?

    func log(level: NovaLogLevel, module: String, file: String, function: String, line: Int, message: String) {
        if shouldLog(level: level) {
            delegate?.novaLog(level: level, module: module, file: file, function: function, line: line, message: message)
        }
    }

    func shouldLog(level: NovaLogLevel) -> Bool {
        delegate?.shouldLog(level: level) ?? false
    }
}

func DLOG(module: String = "Core", file: String = #file, function: String = #function, line: Int = #line, message: String) {
    NovaPrinter.shared.log(level: .debug, module: module, file: file, function: function, line: line, message: message)
}

func ILOG(module: String = "Core", file: String = #file, function: String = #function, line: Int = #line, message: String) {
    NovaPrinter.shared.log(level: .info, module: module, file: file, function: function, line: line, message: message)
}

func WLOG(module: String = "Core", file: String = #file, function: String = #function, line: Int = #line, message: String) {
    NovaPrinter.shared.log(level: .warn, module: module, file: file, function: function, line: line, message: message)
}

func ELOG(module: String = "Core", file: String = #file, function: String = #function, line: Int = #line, message: String) {
    NovaPrinter.shared.log(level: .error, module: module, file: file, function: function, line: line, message: message)
}
