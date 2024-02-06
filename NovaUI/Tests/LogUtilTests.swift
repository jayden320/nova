//
//  LogUtilTests.swift
//  NovaUI_Tests
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
@testable import NovaUI
import XCTest

final class LogUtilTests: XCTestCase {
    let directoryName = "test"

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try LogUtil.cleanDirectory(directoryName: directoryName)
    }

    func testSaveLog() throws {
        // When
        let firstFileName = "first_log"
        let secondFileName = "second_log"

        var logCount = LogUtil.loadSandboxModelCount(directoryName: directoryName)
        XCTAssert(logCount == 0)

        guard let path = LogUtil.saveLog("It's the first log", directoryName: directoryName, fileName: firstFileName) else {
            XCTFail("save fail")
            return
        }

        guard LogUtil.saveLog("It's the second log", directoryName: directoryName, fileName: secondFileName) != nil else {
            XCTFail("save fail")
            return
        }

        // Then
        XCTAssert(path.hasSuffix("Caches/\(directoryName)/\(firstFileName).log"))

        logCount = LogUtil.loadSandboxModelCount(directoryName: directoryName)
        XCTAssert(logCount == 2)

        let models = LogUtil.loadSandboxModels(directoryName: directoryName)
        XCTAssert(models.count == 2)
        XCTAssert(models.first?.name == "\(secondFileName).log")
    }
}
