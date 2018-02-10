//
//  AppEnvironmentTests.swift
//  PacesKitTests
//
//  Created by Mircea Grelus on 2018-02-09.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest
@testable import PacesKit

class AppEnvironmentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testKeysAndDefaults() {
        XCTAssert(AppEnvironment.environmentStorageKey == "com.Paces.AppEnvironment.current")

        XCTAssertEqual(false, AppEnvironment.current.isPremiumUser, "Default value for isPremium is false")
    }

    func testReplaceCurrentEnvironment() {
        var env = Environment(isPremiumUser: true)

        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, env.isPremiumUser)

        env = Environment(isPremiumUser: false)
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, env.isPremiumUser)
    }

    func testFromStorage_NothingStored() {
        let userDefaults: KeyValueStoreType = MockKeyValueStore()
        let env = AppEnvironment.fromStorage(userDefaults: userDefaults)

        XCTAssert(env.isPremiumUser == false)
    }

    func testFromStorage_DatasetStored() {
        let userDefaults: KeyValueStoreType = MockKeyValueStore()
        let dict = ["isPremiumUser" : true]
        userDefaults.set(dict, forKey: AppEnvironment.environmentStorageKey)

        let env = AppEnvironment.fromStorage(userDefaults: userDefaults)

        XCTAssert(env.isPremiumUser == true)
    }

    func testSaveEnvironment() {
        let userDefaults = MockKeyValueStore()
        var env = Environment()

        AppEnvironment.saveEnvironment(environment: env, userDefaults: userDefaults)
        var data = userDefaults.dictionary(forKey: AppEnvironment.environmentStorageKey) ?? [:]
        XCTAssertEqual(env.isPremiumUser, data["isPremiumUser"] as? Bool)

        env = Environment(isPremiumUser: true)
        AppEnvironment.saveEnvironment(environment: env, userDefaults: userDefaults)
        data = userDefaults.dictionary(forKey: AppEnvironment.environmentStorageKey) ?? [:]
        XCTAssertEqual(env.isPremiumUser, data["isPremiumUser"] as? Bool)
    }



    
}
