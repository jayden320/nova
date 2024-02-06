//
//  NovaTests.swift
//  Nova_Tests
//
//  Created by Jayden Liu on 2022/12/7.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
import XCTest

class NovaListener: NovaDelegate {
    var hasReported = false
    var lastIssue: NovaIssue?

    func onReport(_ issue: NovaIssue) {
        hasReported = true
        lastIssue = issue
    }
}

class NovaMockPlugin: NovaPlugin {
    var isStarted = false
    public override class func getTag() -> String {
        "Mock"
    }

    override func start() -> Bool {
        isStarted = true
        return super.start()
    }

    override func stop() {
        isStarted = false
        super.stop()
    }

    func reportIssue() {
        report(NovaIssue(tag: NovaMockPlugin.getTag()))
    }
}

class NovaLogger: NovaLogDelegate {
    var lastMessage: String?

    func shouldLog(level _: NovaLogLevel) -> Bool {
        true
    }

    func novaLog(level _: NovaLogLevel, module _: String, file _: String, function _: String, line _: Int, message: String) {
        lastMessage = message
    }
}

final class NovaTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        NovaLauncher.shared.isEnabled = true
    }

    override func tearDownWithError() throws {
        NovaLauncher.shared.destroy()
    }

    func testLaunch() {
        // When
        NovaLauncher.shared.launch(plugins: [])

        // Then
        XCTAssertTrue(NovaLauncher.shared.isRuning)
    }

    func testNovaPluginDescription() {
        XCTAssertNil(NovaPlugin.description())
        XCTAssertEqual(NovaPlugin.getTag(), "")
    }

    func testStartPlugin() {
        // Given
        NovaLauncher.shared.launch(plugins: [NovaMockPlugin()])
        let tag = NovaMockPlugin.getTag()

        // When
        let isStarted = NovaLauncher.shared.startPlugin(tag)

        // Then
        XCTAssertTrue(isStarted)
        let plugin = NovaLauncher.shared.getPlugin(tag) as! NovaMockPlugin
        XCTAssertTrue(plugin.isStarted)
    }

    func testStartPluginWithoutLaunch() {
        // Given
        NovaLauncher.shared.launch(plugins: [])

        // When
        let isStarted = NovaLauncher.shared.startPlugin(NovaMockPlugin.getTag())

        // Then
        XCTAssertFalse(isStarted)
    }

    func testStopPlugin() {
        // Given
        let plugin = NovaMockPlugin()
        NovaLauncher.shared.launch(plugins: [plugin])
        let tag = NovaMockPlugin.getTag()
        NovaLauncher.shared.startPlugin(tag)

        // When
        NovaLauncher.shared.stopPlugin(tag)

        // Then
        XCTAssertFalse(plugin.isStarted)
    }

    func testStarPlugins() {
        // Given
        let plugin = NovaMockPlugin()
        NovaLauncher.shared.launch(plugins: [plugin])

        // When
        NovaLauncher.shared.starPlugins()

        // Then
        XCTAssertTrue(plugin.isStarted)
    }

    func testStopPlugins() {
        // Given
        let plugin = NovaMockPlugin()
        NovaLauncher.shared.launch(plugins: [plugin])
        NovaLauncher.shared.starPlugins()

        // When
        NovaLauncher.shared.stopPlugins()

        // Then
        XCTAssertFalse(plugin.isStarted)
    }

    func testEnable() {
        XCTAssertTrue(NovaLauncher.shared.isEnabled)

        // When
        NovaLauncher.shared.isEnabled = false

        let logger = NovaLogger()
        NovaLauncher.shared.logDelegate = logger
        NovaLauncher.shared.launch(plugins: [])

        // Then
        XCTAssertFalse(NovaLauncher.shared.isEnabled)
        XCTAssertEqual(logger.lastMessage, "Nova is disabled")
    }

    func testAddListener() {
        // Given
        let listener = NovaListener()
        NovaLauncher.shared.addListener(listener)

        let mockPlugin = NovaMockPlugin()
        NovaLauncher.shared.launch(plugins: [mockPlugin])

        // When
        mockPlugin.reportIssue()

        // Then
        XCTAssertTrue(listener.hasReported)
    }

    func testRemoveListener() {
        // Given
        let listener = NovaListener()
        NovaLauncher.shared.addListener(listener)
        let mockPlugin = NovaMockPlugin()
        NovaLauncher.shared.launch(plugins: [mockPlugin])

        // When
        NovaLauncher.shared.removeListener(listener)
        mockPlugin.reportIssue()

        // Then
        XCTAssertFalse(listener.hasReported)
    }

    func testPerformance() {
        // When
        let count = NovaLauncher.shared.performanceUtil.cpuCoreCount()

        // Then
        XCTAssert(count > 0)
    }

    func testLog() {
        // Given
        let logger = NovaLogger()
        NovaLauncher.shared.logDelegate = logger

        // When
        NovaLauncher.shared.launch(plugins: [])

        // Then
        XCTAssertNotNil(NovaLauncher.shared.logDelegate)
        XCTAssertEqual(logger.lastMessage, "Nova launch successfully")
    }

    func testRunning() {
        // Given
        let logger = NovaLogger()
        NovaLauncher.shared.logDelegate = logger
        NovaLauncher.shared.launch(plugins: [])

        // When
        NovaLauncher.shared.launch(plugins: [])

        // Then
        XCTAssertEqual(logger.lastMessage, "Nova is runing")
    }

    func testDestroy() {
        // Given
        NovaLauncher.shared.launch(plugins: [NovaMockPlugin()])

        // When
        NovaLauncher.shared.destroy()

        // Then
        XCTAssertFalse(NovaLauncher.shared.isRuning)
    }
}
