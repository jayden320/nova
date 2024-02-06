//
//  ExpiredCacheTests.swift
//  Nova_Tests
//
//  Created by Jayden Liu on 2022/12/8.
//  Copyright © 2022 JaydenLiu. All rights reserved.
//

@testable import NovaMetrics
import XCTest

final class ExpiredCacheTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExpired() throws {
        // Given
        let cache = ExpiredCache(name: "unit_test", expiration: 0.5)
        try cache.cleanCacheFile()
        cache.append("something")
        cache.synchronize()

        XCTAssertFalse(cache.isExpired("something"))

        // When
        Thread.sleep(forTimeInterval: 1)

        // Then
        XCTAssertTrue(cache.isExpired("something"))

        let cache2 = ExpiredCache(name: "unit_test", expiration: 0.5)
        XCTAssertTrue(cache2.isExpired("something"))
    }
}
