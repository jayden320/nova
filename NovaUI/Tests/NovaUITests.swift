//
//  NovaUITests.swift
//  NovaUI_Tests
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

import NovaMetrics
@testable import NovaUI
import XCTest

final class NovaUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        NovaUILauncher.shared.hideHomeWindow()
        NovaUILauncher.shared.resetConfig()
        NovaLauncher.shared.destroy()
    }

    func testHomeWindow() {
        // Given
        NovaLauncher.shared.launch(plugins: [])
        NovaLauncher.shared.starPlugins()

        let uiConfig = NovaUIConfig(isIssueLogEnabled: true,
                                    isIssueNotificationEnabled: true,
                                    isFloatingWindowEnabled: true)
        NovaUILauncher.shared.launch(defaultConfig: uiConfig)

        // When
        NovaUILauncher.shared.showNovaPage()

        RunLoop.current.run(until: Date())

        // Then
        XCTAssertFalse(NovaUILauncher.shared.homeWindow.isHidden)
    }

    func testFloatingWindow() {
        // Given
        NovaLauncher.shared.launch(plugins: [])

        let uiConfig = NovaUIConfig(isIssueLogEnabled: true,
                                    isIssueNotificationEnabled: true,
                                    isFloatingWindowEnabled: true)
        NovaUILauncher.shared.launch(defaultConfig: uiConfig)
        RunLoop.current.run(until: Date())
        XCTAssertNotNil(NovaUILauncher.shared.floatingWindow)

        // When
        NovaUILauncher.shared.isFloatingWindowEnabled = false

        // Then
        XCTAssertNil(NovaUILauncher.shared.floatingWindow)
    }
}
