//
//  LogUtil.swift
//  NovaUI
//
//  Created by Jayden Liu on 2022/7/13.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import Foundation

struct SandboxModel {
    let name: String
    let path: String
}

class LogUtil {
    @discardableResult
    static func saveLog(_ string: String, directoryName: String, fileName: String) -> String? {
        guard let directory = LogUtil.createCacheDirectoryIfNeed(directoryName: directoryName) else {
            return nil
        }
        let manager = FileManager.default
        if manager.fileExists(atPath: directory.path) {
            let filePath = getFilePath(directory: directory, fileName: fileName, number: 0)
            do {
                try string.write(toFile: filePath, atomically: true, encoding: .utf8)
                return filePath
            } catch {
//                ELOG(message: error.localizedDescription)
            }
        }
        return nil
    }

    private static func getFilePath(directory: URL, fileName: String, number: Int) -> String {
        let filePath = directory.appendingPathComponent(number == 0 ? "\(fileName).log" : "\(fileName)-\(number).log").path
        if FileManager.default.fileExists(atPath: filePath) {
            return getFilePath(directory: directory, fileName: fileName, number: number + 1)
        } else {
            return filePath
        }
    }

    private static func createCacheDirectoryIfNeed(directoryName: String) -> URL? {
        guard let directory = getCacheDirectory(directoryName) else {
            return nil
        }
        let manager = FileManager.default
        if !manager.fileExists(atPath: directory.path) {
            do {
                try manager.createDirectory(atPath: directory.path, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        return directory
    }

    static func loadSandboxModelCount(directoryName: String) -> Int {
        guard let targetPath = createCacheDirectoryIfNeed(directoryName: directoryName) else {
            return 0
        }

        let fileManager = FileManager.default
        guard let paths = try? fileManager.contentsOfDirectory(atPath: targetPath.path) else {
            return 0
        }
        return paths.count
    }

    static func loadSandboxModels(directoryName: String) -> [SandboxModel] {
        guard let targetPath = createCacheDirectoryIfNeed(directoryName: directoryName) else {
            return []
        }

        let fileManager = FileManager.default
        guard var paths = try? fileManager.contentsOfDirectory(atPath: targetPath.path) else {
            return []
        }

        paths.sort { obj1, obj2 in
            let firstPath = targetPath.appendingPathComponent(obj1).path
            let secondPath = targetPath.appendingPathComponent(obj2).path
            if let firstFileInfo = try? fileManager.attributesOfItem(atPath: firstPath), let secondFileInfo = try? fileManager.attributesOfItem(atPath: secondPath), let firstData = firstFileInfo[.creationDate] as? Date, let secondData = secondFileInfo[.creationDate] as? Date {
                return secondData.timeIntervalSince1970 < firstData.timeIntervalSince1970
            }
            return false
        }

        var files = [SandboxModel]()

        for path in paths {
            let fullPath = targetPath.appendingPathComponent(path)
            let file = SandboxModel(name: path, path: fullPath.path)
            files.append(file)
        }

        return files
    }

    public static func cleanDirectory(directoryName: String) throws {
        guard let path = getCacheDirectory(directoryName) else {
            return
        }
        let manager = FileManager.default
        if manager.fileExists(atPath: path.path) {
            try manager.removeItem(at: path)
        }
    }

    static func getCacheDirectory(_ directoryName: String) -> URL? {
        guard let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cachePath.appendingPathComponent(directoryName)
    }
}
