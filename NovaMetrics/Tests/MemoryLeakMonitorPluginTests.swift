//
//  MemoryLeakMonitorPluginTests.swift
//  Nova_Tests
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

@testable import NovaMetrics
import XCTest

final class MemoryLeakMonitorPluginTests: XCTestCase {
    var listener: NovaListener?
    let plugin = MemoryLeakMonitorPlugin()

    var pageVC: UIPageViewController?
    var tabVC: UITabBarController?

    override func setUpWithError() throws {
        listener = NovaListener()

        NovaLauncher.shared.addListener(listener!)
        NovaLauncher.shared.launch(plugins: [plugin])

        plugin.start()
    }

    override func tearDownWithError() throws {
        pageVC = nil
        tabVC = nil
        listener = nil
        NovaLauncher.shared.destroy()
    }

    func testStrategy() {
        UserDefaults.standard.removeObject(forKey: MemoryLeakMonitorPlugin.strategyKey)
        XCTAssertEqual(MemoryLeakMonitorPlugin().reportStrategy, .everyTime)

        // When
        plugin.reportStrategy = .onceADay

        // Then
        XCTAssertEqual(MemoryLeakMonitorPlugin().reportStrategy, .onceADay)
    }

    func testPageViewControllerLeak() {
        // When
        pageVC = UIPageViewController()
        pushViewControllerThenPop(viewController: pageVC!)

        // Then
        checkIssue()
    }

    func testUITabBarControllerLeak() {
        // When
        tabVC = UITabBarController()
        pushViewControllerThenPop(viewController: tabVC!)

        // Then
        checkIssue()
    }

    private func pushViewControllerThenPop(viewController: UIViewController) {
        let rootVC = UINavigationController(rootViewController: UIViewController())
        UIApplication.shared.keyWindow?.rootViewController = rootVC
    
        RunLoop.current.run(until: Date())
        
        rootVC.pushViewController(viewController, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rootVC.popViewController(animated: false)
        }
    }

    private func checkIssue() {
        let expectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            guard let lastIssue = self.listener?.lastIssue, lastIssue.tag == MemoryLeakMonitorPlugin.getTag() else {
                XCTFail("Memory leak is not triggered")
                return
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
