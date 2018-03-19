//
//  PaceTests.swift
//  PacesKitTests
//
//  Created by Mircea Grelus on 2018-02-11.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest
@testable import PacesKit

class PaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSpeedPacingUnit() {
        let pace1 = Pace(value: 0, unit: .minPerKm)
        let pace2 = Pace(value: 0, unit: .minPerMile)
        let pace3 = Pace(value: 0, unit: .kmPerHour)
        let pace4 = Pace(value: 0, unit: .milePerHour)

        let pacings = [pace1, pace2, pace3, pace4].map { $0.isPacingUnit }
        XCTAssertEqual(pacings, [true, true, false, false])
        let speeds = [pace1, pace2, pace3, pace4].map { $0.isSpeedUnit }
        XCTAssertEqual(speeds, [false, false, true, true])
    }

    func testDisplayValue() {
        let pace1 = Pace.minPerKm(seconds: 5 * 60 + 30)
        let pace2 = Pace.minPerKm(seconds: 3 * 60 + 5)
        let pace3 = Pace.minPerMile(seconds: 10 * 60 + 0)
        let pace4 = Pace(value: 20, unit: .kmPerHour)
        let pace5 = Pace(value: 10.7, unit: .milePerHour)

        XCTAssertEqual(pace1.displayValue, "5:30")
        XCTAssertEqual(pace2.displayValue, "3:05")
        XCTAssertEqual(pace3.displayValue, "10:00")
        XCTAssertEqual(pace4.displayValue, "20.0")
        XCTAssertEqual(pace5.displayValue, "10.7")
    }

    func testDisplayUnit() {
        let pace1 = Pace(value: 0, unit: .minPerKm)
        let pace2 = Pace(value: 0, unit: .minPerMile)
        let pace3 = Pace(value: 0, unit: .kmPerHour)
        let pace4 = Pace(value: 0, unit: .milePerHour)

        let paces = [pace1, pace2, pace3, pace4].map { $0.displayUnit }
        XCTAssertEqual(paces, ["min/km", "min/mi", "kph", "mph"])
    }

    func testConvenieceConstructors() {
        let pace1 = Pace.minPerKm(seconds: 3 * 60 + 35)
        XCTAssertEqual(pace1.value, (3 * 60 + 35) / 60.0 )

        let pace2 = Pace.minPerMile(seconds: 9 * 60 + 00)
        XCTAssertEqual(pace2.value, (9 * 60 + 00) / 60.0 )

        let pace3 = Pace(stringValue: "4:45", unit: .minPerKm)
        XCTAssertEqual(pace3.value, (4 * 60 + 45) / 60.0 )
    }

    func testUpdateValue_valid() {
        var pace1 = Pace(value: 0, unit: .minPerKm)
        pace1.updateValue("3:35")
        XCTAssertEqual(pace1.value, (3 * 60 + 35) / 60.0)
        XCTAssertEqual(pace1.displayValue, "3:35")

        var pace2 = Pace(value: 0, unit: .minPerMile)
        pace2.updateValue("8:30")
        XCTAssertEqual(pace2.value, (8 * 60 + 30) / 60.0)
        XCTAssertEqual(pace2.displayValue, "8:30")

        var pace3 = Pace(value: 0, unit: .kmPerHour)
        pace3.updateValue("22")
        XCTAssertEqual(pace3.value, 22)
        XCTAssertEqual(pace3.displayValue, "22.0")

        var pace4 = Pace(value: 0, unit: .kmPerHour)
        pace4.updateValue("9.5")
        XCTAssertEqual(pace4.value, 9.5)
        XCTAssertEqual(pace4.displayValue, "9.5")
    }

    func testUpdateValue_invalid() {
        var pace1 = Pace(value: 10, unit: .kmPerHour)
        pace1.updateValue("")
        XCTAssertEqual(pace1.value, 10)

        var pace2 = Pace(value: 10, unit: .kmPerHour)
        pace2.updateValue("3:35")
        XCTAssertEqual(pace2.value, 10)

        var pace3 = Pace(value: 9.5, unit: .milePerHour)
        pace3.updateValue("1:0")
        XCTAssertEqual(pace3.value, 9.5)

        var pace4 = Pace(value: 5 * 60 + 30, unit: .minPerKm)
        pace4.updateValue("1")
        XCTAssertEqual(pace4.value, 5 * 60 + 30)

        var pace5 = Pace(value: 10 * 60 + 0, unit: .minPerMile)
        pace5.updateValue("10")
        XCTAssertEqual(pace5.value, 10 * 60 + 0)
    }

    func testConversions() {
        let pace1 = Pace.minPerKm(seconds: 5 * 60 + 36)
        let pace1Conv1 = pace1.converted(to: .minPerMile)
        let pace1Conv2 = pace1.converted(to: .kmPerHour)
        let pace1Conv3 = pace1.converted(to: .milePerHour)
        let pace1Conv4 = pace1.converted(to: .minPerKm)
        let pace1Conv5 = pace1.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let pace1Conv6 = pace1.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let pace1Conv7 = pace1.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let pace1Conv8 = pace1.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let pace1Conv9 = pace1.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(pace1Conv1.displayValue, "9:01")
        XCTAssertEqual(pace1Conv2.displayValue, "10.7")
        XCTAssertEqual(pace1Conv3.displayValue, "6.7")
        XCTAssertEqual(pace1Conv4.displayValue, "5:36")
        XCTAssertEqual(pace1Conv5.displayValue, "3:56:18")
        XCTAssertEqual(pace1Conv6.displayValue, "1:58:09")
        XCTAssertEqual(pace1Conv7.displayValue, "0:56:00")
        XCTAssertEqual(pace1Conv8.displayValue, "0:28:00")
        XCTAssertEqual(pace1Conv9.displayValue, "9:20:00")

        let pace2 = Pace.minPerMile(seconds: 9 * 60 + 35)
        let pace2Conv1 = pace2.converted(to: .minPerKm)
        let pace2Conv2 = pace2.converted(to: .kmPerHour)
        let pace2Conv3 = pace2.converted(to: .milePerHour)
        let pace2Conv4 = pace2.converted(to: .minPerMile)
        let pace2Conv5 = pace2.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let pace2Conv6 = pace2.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let pace2Conv7 = pace2.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let pace2Conv8 = pace2.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let pace2Conv9 = pace2.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(pace2Conv1.displayValue, "5:57")
        XCTAssertEqual(pace2Conv2.displayValue, "10.1")
        XCTAssertEqual(pace2Conv3.displayValue, "6.3")
        XCTAssertEqual(pace2Conv4.displayValue, "9:35")
        XCTAssertEqual(pace2Conv5.displayValue, "4:11:16")
        XCTAssertEqual(pace2Conv6.displayValue, "2:05:38")
        XCTAssertEqual(pace2Conv7.displayValue, "0:59:33")
        XCTAssertEqual(pace2Conv8.displayValue, "0:29:46")
        XCTAssertEqual(pace2Conv9.displayValue, "9:55:29")

        let pace3 = Pace(value: 10, unit: .kmPerHour)
        let pace3Conv1 = pace3.converted(to: .minPerKm)
        let pace3Conv2 = pace3.converted(to: .minPerMile)
        let pace3Conv3 = pace3.converted(to: .milePerHour)
        let pace3Conv4 = pace3.converted(to: .kmPerHour)
        let pace3Conv5 = pace3.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let pace3Conv6 = pace3.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let pace3Conv7 = pace3.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let pace3Conv8 = pace3.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let pace3Conv9 = pace3.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(pace3Conv1.displayValue, "6:00")
        XCTAssertEqual(pace3Conv2.displayValue, "9:39")
        XCTAssertEqual(pace3Conv3.displayValue, "6.2")
        XCTAssertEqual(pace3Conv4.displayValue, "10.0")
        XCTAssertEqual(pace3Conv5.displayValue, "4:13:10")
        XCTAssertEqual(pace3Conv6.displayValue, "2:06:35")
        XCTAssertEqual(pace3Conv7.displayValue, "1:00:00")
        XCTAssertEqual(pace3Conv8.displayValue, "0:30:00")
        XCTAssertEqual(pace3Conv9.displayValue, "10:00:00")

        let pace4 = Pace(value: 10.5, unit: .milePerHour)
        let pace4Conv1 = pace4.converted(to: .minPerKm)
        let pace4Conv2 = pace4.converted(to: .minPerMile)
        let pace4Conv3 = pace4.converted(to: .kmPerHour)
        let pace4Conv4 = pace4.converted(to: .milePerHour)
        let pace4Conv5 = pace4.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let pace4Conv6 = pace4.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let pace4Conv7 = pace4.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let pace4Conv8 = pace4.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let pace4Conv9 = pace4.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(pace4Conv1.displayValue, "3:33")
        XCTAssertEqual(pace4Conv2.displayValue, "5:43")
        XCTAssertEqual(pace4Conv3.displayValue, "16.9")
        XCTAssertEqual(pace4Conv4.displayValue, "10.5")
        XCTAssertEqual(pace4Conv5.displayValue, "2:29:49")
        XCTAssertEqual(pace4Conv6.displayValue, "1:14:55")
        XCTAssertEqual(pace4Conv7.displayValue, "0:35:30")
        XCTAssertEqual(pace4Conv8.displayValue, "0:17:45")
        XCTAssertEqual(pace4Conv9.displayValue, "5:55:04")
    }

    func testEquality() {
        let pace1 = Pace.minPerKm(seconds: 3*60 + 20)
        let pace2 = Pace.minPerMile(seconds: 8*60)
        let pace3 = Pace(value: 23.2, unit: .kmPerHour)
        let pace4 = Pace(value: 28.1, unit: .milePerHour)

        let pace1s = Pace(stringValue: "3:20", unit: .minPerKm)
        let pace2s = Pace(stringValue: "8:00", unit: .minPerMile)
        let pace3s = Pace(stringValue: "23.2", unit: .kmPerHour)
        let pace4s = Pace(stringValue: "28.1", unit: .milePerHour)

        XCTAssertEqual(pace1, pace1s)
        XCTAssertEqual(pace2, pace2s)
        XCTAssertEqual(pace3, pace3s)
        XCTAssertEqual(pace4, pace4s)
    }

    func testPaceUnitIsPacing() {
        let paceUnits: [PaceUnit] = [.minPerKm, .minPerMile, .kmPerHour, .milePerHour]
        XCTAssertEqual(paceUnits.map { $0.isPacingUnit }, [true, true, false, false])

    }

    func testPaceUnitIsSpeed() {
        let paceUnits: [PaceUnit] = [.minPerKm, .minPerMile, .kmPerHour, .milePerHour]
        XCTAssertEqual(paceUnits.map { $0.isSpeedUnit }, [false, false, true, true])

    }

    func testPaceUnitDescription() {
        let paceUnits: [PaceUnit] = [.minPerKm, .minPerMile, .kmPerHour, .milePerHour]
        XCTAssertEqual(paceUnits.map { $0.description }, ["min/km", "min/mi", "kph", "mph"])
    }

    func testPaceUnitInputSource() {
        XCTAssertTrue(PaceUnit.minPerKm.inputSource.elementsEqual(PaceUnit.paceInputs) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })

        XCTAssertTrue(PaceUnit.minPerMile.inputSource.elementsEqual(PaceUnit.paceInputs) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })

        XCTAssertTrue(PaceUnit.kmPerHour.inputSource.elementsEqual(PaceUnit.speedInputs) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })

        XCTAssertTrue(PaceUnit.milePerHour.inputSource.elementsEqual(PaceUnit.speedInputs) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
    }

    func testPaceUnitDistanceUnit() {
        let paceUnits: [PaceUnit] = [.minPerKm, .minPerMile, .kmPerHour, .milePerHour]
        XCTAssertEqual(paceUnits.map { $0.distanceUnit }, [.km, .mile, .km, .mile])
    }

    func testPaceUnitToUnitSpeed() {
        XCTAssertEqual(PaceUnit.minPerKm.toUnitSpeed(), UnitSpeed.minutesPerKilometer)
        XCTAssertEqual(PaceUnit.minPerMile.toUnitSpeed(), UnitSpeed.minutesPerMile)
        XCTAssertEqual(PaceUnit.kmPerHour.toUnitSpeed(), UnitSpeed.kilometersPerHour)
        XCTAssertEqual(PaceUnit.milePerHour.toUnitSpeed(), UnitSpeed.milesPerHour)
    }
}




