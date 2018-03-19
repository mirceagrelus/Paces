//
//  PaceTypeTests.swift
//  PacesKitTests
//
//  Created by Mircea Grelus on 2018-03-17.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest
@testable import PacesKit

class PaceTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDisplayValue() {
        let pace = PaceType.pace(Pace(value: 10.7, unit: .milePerHour))
        let paceUpdated = pace.withUpdatedValue("21.5")
        XCTAssertEqual(paceUpdated.displayValue, "21.5")

        let race = PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km)))
        let raceUpdated = race.withUpdatedValue("3:45:00")
        XCTAssertEqual(raceUpdated.displayValue, "3:45:00")
    }

    func testDistanceUnit() {
        let pace = PaceType.pace(Pace(value: 10.7, unit: .minPerMile))
        XCTAssertEqual(pace.distanceUnit, DistanceUnit.mile)

        let race = PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km)))
        XCTAssertEqual(race.distanceUnit, DistanceUnit.km)
    }

    func testConversions() {
        let paceType1 = PaceType.pace(Pace.minPerKm(seconds: 5*60 + 30))
        let paceType1Conv1 = paceType1.converted(to: .pace(Pace(value: 0, unit: .milePerHour)))
        let paceType1Conv2 = paceType1.converted(to: .race(Race(time: 0, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))))
        XCTAssertEqual(paceType1Conv1.displayValue, "6.8")
        XCTAssertEqual(paceType1Conv2.displayValue, "3:52:04")

        let paceType2 = PaceType.race(Race(time: 3*3600 + 5*60, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .mile)))
        let paceType2Conv1 = paceType2.converted(to: .pace(Pace(value: 0, unit: .milePerHour)))
        let paceType2Conv2 = paceType2.converted(to: .race(Race(time: 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))))
        XCTAssertEqual(paceType2Conv1.displayValue, "8.5")
        XCTAssertEqual(paceType2Conv2.displayValue, "1:32:30")

    }

    func testWithUpdatedValue() {
        let pace = PaceType.pace(Pace(value: 0, unit: .minPerKm))
        let paceUpdated = pace.withUpdatedValue("2:33")
        XCTAssertEqual(paceUpdated.displayValue, "2:33")

        let race = PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km)))
        let raceUpdated = race.withUpdatedValue("1:30:05")
        XCTAssertEqual(raceUpdated.displayValue, "1:30:05")
    }

    func testEqualUnits() {
        XCTAssertTrue(PaceType.equalUnits(lhs: .pace(Pace.minPerKm(seconds: 5*60 + 30)),
                                          rhs: .pace(Pace.minPerKm(seconds: 35))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .pace(Pace.minPerMile(seconds: 1*60 + 30)),
                                          rhs: .pace(Pace.minPerMile(seconds: 3*60))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .pace(Pace(value: 20, unit: .kmPerHour)),
                                          rhs: .pace(Pace(value: 5, unit: .kmPerHour))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .pace(Pace(value: 10, unit: .milePerHour)),
                                          rhs: .pace(Pace(value: 5, unit: .milePerHour))))

        XCTAssertTrue(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))),
                                          rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km)))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))),
                                          rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km)))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))),
                                          rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km)))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))),
                                          rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km)))))
        XCTAssertTrue(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .km))),
                                          rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .km)))))

        // different units
        XCTAssertFalse(PaceType.equalUnits(lhs: .pace(Pace.minPerKm(seconds: 5*60 + 30)),
                                           rhs: .pace(Pace.minPerMile(seconds: 5*60 + 30))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .pace(Pace.minPerMile(seconds: 1*60 + 30)),
                                           rhs: .pace(Pace(value: 20, unit: .kmPerHour))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .pace(Pace(value: 20, unit: .kmPerHour)),
                                           rhs: .pace(Pace(value: 5, unit: .milePerHour))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .pace(Pace(value: 10, unit: .milePerHour)),
                                           rhs: .pace(Pace.minPerKm(seconds: 5*60 + 30))))

        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .mile)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .mile)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .mile)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .mile)))))

        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .custom(40), distanceUnit: .km)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .custom(30), distanceUnit: .km))),
                                           rhs: .race(Race(time: 70, raceDistance: RaceDistance(raceType: .custom(40), distanceUnit: .mile)))))

        XCTAssertFalse(PaceType.equalUnits(lhs: .pace(Pace.minPerKm(seconds: 5*60 + 30)),
                                           rhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km)))))
        XCTAssertFalse(PaceType.equalUnits(lhs: .race(Race(time: 50, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))),
                                           rhs: .pace(Pace(value: 5, unit: .kmPerHour))))
    }

    func testDefaultValue() {
        XCTAssertEqual(PaceType.defaultValue, PaceType.pace(Pace.minPerMile(seconds: 0)))
    }

    func testEquality() {
        XCTAssertEqual(PaceType.pace(Pace.minPerKm(seconds: 5*60 + 30)),
                       PaceType.pace(Pace.minPerKm(seconds: 5*60 + 30)))
        XCTAssertEqual(PaceType.race(Race(time: 300, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))),
                       PaceType.race(Race(time: 300, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))))

        XCTAssertNotEqual(PaceType.pace(Pace.minPerKm(seconds: 5*60 + 30)),
                          PaceType.race(Race(time: 300, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))))
        XCTAssertNotEqual(PaceType.race(Race(time: 300, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))),
                          PaceType.pace(Pace.minPerKm(seconds: 5*60 + 30)))
    }
    
}
