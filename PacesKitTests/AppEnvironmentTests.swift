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

    func testPushAndPopEnvironment() {
        let theme = AppEnvironment.current.theme
        let isPremium = AppEnvironment.current.isPremiumUser

        AppEnvironment.pushEnvironment(Environment())
        XCTAssertEqual(AppEnvironment.current.theme.themeType, theme.themeType)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, isPremium)

        AppEnvironment.pushEnvironment(Environment(theme: ThemeType.solidBlue.theme(), isPremiumUser: true))
        XCTAssertEqual(AppEnvironment.current.theme.themeType, ThemeType.solidBlue)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, true)

        AppEnvironment.popEnvironment()

        XCTAssertEqual(AppEnvironment.current.theme.themeType, theme.themeType)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, isPremium)

        AppEnvironment.popEnvironment()
    }

    func testKeysAndDefaults() {
        XCTAssertEqual(AppEnvironment.environmentStorageKey, "com.Paces.AppEnvironment.current")

        AppEnvironment.pushEnvironment(Environment())

        XCTAssertEqual(AppEnvironment.current.isPremiumUser, false)
        XCTAssertEqual(AppEnvironment.current.archivedControls, Environment.defaultControls)
        XCTAssertEqual(AppEnvironment.current.inputValue, "8:00")
        XCTAssertEqual(AppEnvironment.current.inputPaceType, .pace(Pace.minPerMile(seconds: 8*60)))
        XCTAssertEqual(AppEnvironment.current.theme.themeType, ThemeType.orangeRed)

        XCTAssertEqual(AppEnvironment.current.appConfig.appId, "1359792411")
        XCTAssertEqual(AppEnvironment.current.appConfig.contactEmail, "mircea@codexbit.com")
        XCTAssertEqual(AppEnvironment.current.appConfig.twitter, "mirceagrelus")
        XCTAssertEqual(AppEnvironment.current.appConfig.website, "http://codexbit.com")

        AppEnvironment.popEnvironment()
    }

    func testReplaceCurrentEnvironment() {
        var env = Environment()
        AppEnvironment.pushEnvironment(env)

        env = Environment(isPremiumUser: true)
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.isPremiumUser, true)

        env = Environment(theme: ThemeType.solidBlue.theme())
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.theme.themeType, ThemeType.solidBlue)

        env = Environment(inputValue: "3:33")
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.inputValue, "3:33")

        env = Environment(inputPaceType: .pace(Pace.minPerKm(seconds: 2*60 + 45)))
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.inputPaceType, .pace(Pace.minPerKm(seconds: 2*60 + 45)))

        let controls = [ConversionControl(id: 0, paceType: .pace(Pace(value: 0, unit: .minPerMile))),
                        ConversionControl(id: 1, paceType: .race(Race(time: 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km)) ))]
        env = Environment(archivedControls: controls)
        AppEnvironment.replaceCurrentEnvironment(env)
        XCTAssertEqual(AppEnvironment.current.archivedControls, controls)

        AppEnvironment.popEnvironment()
    }

    func testFromStorage_NothingStored() {
        AppEnvironment.pushEnvironment(Environment())

        let userDefaults: KeyValueStoreType = MockKeyValueStore()
        let env = AppEnvironment.fromStorage(userDefaults: userDefaults)

        XCTAssertEqual(env.isPremiumUser, false)
        XCTAssertEqual(env.archivedControls, Environment.defaultControls)
        XCTAssertEqual(env.inputValue, "8:00")
        XCTAssertEqual(env.inputPaceType, .pace(Pace.minPerMile(seconds: 8*60)))
        XCTAssertEqual(env.theme.themeType, ThemeType.orangeRed)

        AppEnvironment.popEnvironment()
    }

    func testFromStorage_DatasetStored() {
        AppEnvironment.pushEnvironment(Environment())

        let userDefaults: KeyValueStoreType = MockKeyValueStore()

        let encoder = JSONEncoder()
        let paceData = try? encoder.encode(PaceType.pace(Pace.minPerKm(seconds: 0)))
        let encodedPaceType = paceData != nil ? String(decoding: paceData!, as: UTF8.self) : ""
        let paceTypes = [PaceType.pace(Pace.minPerKm(seconds: 0)),
                         PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km)))]
        let paceTypeData = try? encoder.encode(paceTypes)
        let encodedControls = paceTypeData != nil ? String(decoding: paceTypeData!, as: UTF8.self) : ""
        let dict: [String: Any] = [AppEnvironment.key_isPremiumUser : true,
                                   AppEnvironment.key_themeType: ThemeType.lightPurple.rawValue,
                                   AppEnvironment.key_inputPaceValue: "3:45",
                                   AppEnvironment.key_inputPaceType: encodedPaceType,
                                   AppEnvironment.key_archivedControls: encodedControls]
        userDefaults.set(dict, forKey: AppEnvironment.environmentStorageKey)

        let env = AppEnvironment.fromStorage(userDefaults: userDefaults)

        XCTAssertEqual(env.isPremiumUser, true)
        XCTAssertEqual(env.theme.themeType, ThemeType.lightPurple)
        XCTAssertEqual(env.inputValue, "3:45")
        XCTAssertEqual(env.inputPaceType, PaceType.pace(Pace.minPerKm(seconds: 0)))
        XCTAssertEqual(env.archivedControls, paceTypes.enumerated().map { ConversionControl(id: $0, paceType: $1)  })

        AppEnvironment.popEnvironment()
    }

    func testSaveEnvironment() {
        let userDefaults = MockKeyValueStore()
        let inputPaceType = PaceType.pace(Pace(value: 0, unit: .kmPerHour))
        let paceTypes = [PaceType.pace(Pace.minPerMile(seconds: 0)),
                        PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))) ]

        let env = Environment(theme: ThemeType.solidGreen.theme(),
                              isPremiumUser: true,
                              inputValue: "2:10",
                              inputPaceType: inputPaceType,
                              archivedControls: paceTypes.enumerated().map { ConversionControl(id: $0, paceType:$1) },
                              userDefaults: userDefaults)
        AppEnvironment.saveEnvironment(environment: env, userDefaults: userDefaults)
        let results = userDefaults.dictionary(forKey: AppEnvironment.environmentStorageKey) ?? [:]

        XCTAssertEqual(true, results[AppEnvironment.key_isPremiumUser] as? Bool)
        XCTAssertEqual(ThemeType.solidGreen.rawValue, results[AppEnvironment.key_themeType] as? String)
        XCTAssertEqual("2:10", results[AppEnvironment.key_inputPaceValue] as? String)

        let encoder = JSONEncoder()
        let inputPaceTypeData = try? encoder.encode(inputPaceType)
        let inputPaceTypeString = inputPaceTypeData != nil ? String(decoding: inputPaceTypeData!, as: UTF8.self) : ""
        XCTAssertEqual(inputPaceTypeString, results[AppEnvironment.key_inputPaceType] as? String)

        let paceTypesData = try? encoder.encode(paceTypes)
        let paceTypesString = paceTypesData != nil ? String(decoding: paceTypesData!, as: UTF8.self) : ""
        XCTAssertEqual(paceTypesString, results[AppEnvironment.key_archivedControls] as? String)
    }

}
