//
//  RaceTests.swift
//  PacesKitTests
//
//  Created by Mircea Grelus on 2018-03-17.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest
@testable import PacesKit

class RaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInputSource() {
        let race1 = Race(time: 2*3600 + 34*60 + 35, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2 = Race(time: 1*3600 + 5*60 + 5, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3 = Race(time: 59*60 + 0, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4 = Race(time: 20*60, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5 = Race(time: 6*3600, raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))
        let inputSource: [[CustomStringConvertible]] = [Array(0...99),
                                                        [":"],
                                                        Array(0...59).map { String(format: "%02d", arguments:[$0]) },
                                                        [":"],
                                                        Array(0...59).map { String(format: "%02d", arguments:[$0]) }]

        XCTAssertTrue(race1.inputSource.elementsEqual(inputSource) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
        XCTAssertTrue(race2.inputSource.elementsEqual(inputSource) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
        XCTAssertTrue(race3.inputSource.elementsEqual(inputSource) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
        XCTAssertTrue(race4.inputSource.elementsEqual(inputSource) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
        XCTAssertTrue(race5.inputSource.elementsEqual(inputSource) { array1, array2 -> Bool in
            array1.elementsEqual(array2, by: { $0.description == $1.description })
        })
    }
    
    func testDisplayValue() {
        let race1 = Race(time: 2*3600 + 34*60 + 35, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2 = Race(time: 1*3600 + 5*60 + 5, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3 = Race(time: 59*60 + 0, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4 = Race(time: 20*60, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5 = Race(time: 6*3600, raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))

        XCTAssertEqual(race1.displayValue, "2:34:35")
        XCTAssertEqual(race2.displayValue, "1:05:05")
        XCTAssertEqual(race3.displayValue, "0:59:00")
        XCTAssertEqual(race4.displayValue, "0:20:00")
        XCTAssertEqual(race5.displayValue, "6:00:00")
    }
    
    func testConstructors() {
        let time1: Double = 3*3600 + 9*60 + 5
        let time2: Double = 1*3600 + 10*60 + 59
        let time3: Double = 50*60 + 0
        let time4: Double = 23*60 + 34
        let time5: Double = 10*3600
        let race1 = Race(time: time1, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2 = Race(time: time2, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3 = Race(time: time3, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4 = Race(time: time4, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5 = Race(time: time5, raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))

        let race1s = Race(stringValue: "3:09:05", raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2s = Race(stringValue: "1:10:59", raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3s = Race(stringValue: "0:50:00", raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4s = Race(stringValue: "0:23:34", raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5s = Race(stringValue: "10:00:00", raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))

        XCTAssertEqual(race1.time, time1)
        XCTAssertEqual(race2.time, time2)
        XCTAssertEqual(race3.time, time3)
        XCTAssertEqual(race4.time, time4)
        XCTAssertEqual(race5.time, time5)
        XCTAssertEqual(race1s.time, time1)
        XCTAssertEqual(race2s.time, time2)
        XCTAssertEqual(race3s.time, time3)
        XCTAssertEqual(race4s.time, time4)
        XCTAssertEqual(race5s.time, time5)
    }

    func testUpdateValue() {
        var race1 = Race(time: 3*3600 + 9*60 + 5, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .mile))
        var race2 = Race(time: 1*3600 + 10*60 + 59, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        var race3 = Race(time: 50*60 + 0, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .mile))
        var race4 = Race(time: 23*60 + 34, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .mile))
        var race5 = Race(time: 10*3600, raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .km))

        race1.updateValue("4:14:04")
        XCTAssertEqual(race1.time, 4*3600 + 14*60 + 4)

        race2.updateValue("2:02:02")
        XCTAssertEqual(race2.time, 2*3600 + 2*60 + 2)

        race3.updateValue("0:40:10")
        XCTAssertEqual(race3.time, 40*60 + 10)

        race4.updateValue("0:19:19")
        XCTAssertEqual(race4.time, 19*60 + 19)

        race5.updateValue("9:20:05")
        XCTAssertEqual(race5.time, 9*3600 + 20*60 + 5)
    }

    func testConversions() {
        let race1 = Race(time: 3*3600 + 9*60 + 5, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .mile))
        let race1Conv1 = race1.converted(to: .minPerMile)
        let race1Conv2 = race1.converted(to: .kmPerHour)
        let race1Conv3 = race1.converted(to: .milePerHour)
        let race1Conv4 = race1.converted(to: .minPerKm)
        let race1Conv5 = race1.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race1Conv6 = race1.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race1Conv7 = race1.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race1Conv8 = race1.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race1Conv9 = race1.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(race1Conv1.displayValue, "7:13")
        XCTAssertEqual(race1Conv2.displayValue, "13.4")
        XCTAssertEqual(race1Conv3.displayValue, "8.3")
        XCTAssertEqual(race1Conv4.displayValue, "4:29")
        XCTAssertEqual(race1Conv5.displayValue, "3:09:05")
        XCTAssertEqual(race1Conv6.displayValue, "1:34:33")
        XCTAssertEqual(race1Conv7.displayValue, "0:44:49")
        XCTAssertEqual(race1Conv8.displayValue, "0:22:24")
        XCTAssertEqual(race1Conv9.displayValue, "7:28:07")

        let race2 = Race(time: 1*3600 + 30*60 + 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race2Conv1 = race2.converted(to: .minPerKm)
        let race2Conv2 = race2.converted(to: .kmPerHour)
        let race2Conv3 = race2.converted(to: .milePerHour)
        let race2Conv4 = race2.converted(to: .minPerMile)
        let race2Conv5 = race2.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .mile))
        let race2Conv6 = race2.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let race2Conv7 = race2.converted(to: RaceDistance(raceType: .km10, distanceUnit: .mile))
        let race2Conv8 = race2.converted(to: RaceDistance(raceType: .km5, distanceUnit: .mile))
        let race2Conv9 = race2.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .mile))
        XCTAssertEqual(race2Conv1.displayValue, "4:16")
        XCTAssertEqual(race2Conv2.displayValue, "14.1")
        XCTAssertEqual(race2Conv3.displayValue, "8.7")
        XCTAssertEqual(race2Conv4.displayValue, "6:52")
        XCTAssertEqual(race2Conv5.displayValue, "3:00:00")
        XCTAssertEqual(race2Conv6.displayValue, "1:30:00")
        XCTAssertEqual(race2Conv7.displayValue, "0:42:40")
        XCTAssertEqual(race2Conv8.displayValue, "0:21:20")
        XCTAssertEqual(race2Conv9.displayValue, "11:26:32")

        let race3 = Race(time: 50*60 + 0, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race3Conv1 = race3.converted(to: .minPerKm)
        let race3Conv2 = race3.converted(to: .minPerMile)
        let race3Conv3 = race3.converted(to: .milePerHour)
        let race3Conv4 = race3.converted(to: .kmPerHour)
        let race3Conv5 = race3.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race3Conv6 = race3.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3Conv7 = race3.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race3Conv8 = race3.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race3Conv9 = race3.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(race3Conv1.displayValue, "5:00")
        XCTAssertEqual(race3Conv2.displayValue, "8:03")
        XCTAssertEqual(race3Conv3.displayValue, "7.5")
        XCTAssertEqual(race3Conv4.displayValue, "12.0")
        XCTAssertEqual(race3Conv5.displayValue, "3:30:59")
        XCTAssertEqual(race3Conv6.displayValue, "1:45:29")
        XCTAssertEqual(race3Conv7.displayValue, "0:50:00")
        XCTAssertEqual(race3Conv8.displayValue, "0:25:00")
        XCTAssertEqual(race3Conv9.displayValue, "8:20:00")

        let race4 = Race(time: 17*60 + 30, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race4Conv1 = race4.converted(to: .minPerKm)
        let race4Conv2 = race4.converted(to: .minPerMile)
        let race4Conv3 = race4.converted(to: .kmPerHour)
        let race4Conv4 = race4.converted(to: .milePerHour)
        let race4Conv5 = race4.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race4Conv6 = race4.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let race4Conv7 = race4.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4Conv8 = race4.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race4Conv9 = race4.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(race4Conv1.displayValue, "3:30")
        XCTAssertEqual(race4Conv2.displayValue, "5:38")
        XCTAssertEqual(race4Conv3.displayValue, "17.1")
        XCTAssertEqual(race4Conv4.displayValue, "10.7")
        XCTAssertEqual(race4Conv5.displayValue, "2:27:41")
        XCTAssertEqual(race4Conv6.displayValue, "1:13:50")
        XCTAssertEqual(race4Conv7.displayValue, "0:35:00")
        XCTAssertEqual(race4Conv8.displayValue, "0:17:30")
        XCTAssertEqual(race4Conv9.displayValue, "5:50:00")

        let race5 = Race(time: 2*3600 + 50*60, raceDistance: RaceDistance(raceType: .custom(80), distanceUnit: .km))
        let race5Conv1 = race5.converted(to: .minPerKm)
        let race5Conv2 = race5.converted(to: .minPerMile)
        let race5Conv3 = race5.converted(to: .kmPerHour)
        let race5Conv4 = race5.converted(to: .milePerHour)
        let race5Conv5 = race5.converted(to: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race5Conv6 = race5.converted(to: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let race5Conv7 = race5.converted(to: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race5Conv8 = race5.converted(to: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5Conv9 = race5.converted(to: RaceDistance(raceType: .custom(100), distanceUnit: .km))
        XCTAssertEqual(race5Conv1.displayValue, "2:08")
        XCTAssertEqual(race5Conv2.displayValue, "3:25")
        XCTAssertEqual(race5Conv3.displayValue, "28.2")
        XCTAssertEqual(race5Conv4.displayValue, "17.5")
        XCTAssertEqual(race5Conv5.displayValue, "1:29:40")
        XCTAssertEqual(race5Conv6.displayValue, "0:44:50")
        XCTAssertEqual(race5Conv7.displayValue, "0:21:15")
        XCTAssertEqual(race5Conv8.displayValue, "0:10:38")
        XCTAssertEqual(race5Conv9.displayValue, "3:32:30")
    }

    func testEquality() {
        let time1: Double = 3*3600 + 9*60 + 5
        let time2: Double = 1*3600 + 10*60 + 59
        let time3: Double = 50*60 + 0
        let time4: Double = 23*60 + 34
        let time5: Double = 10*3600
        let race1 = Race(time: time1, raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2 = Race(time: time2, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3 = Race(time: time3, raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4 = Race(time: time4, raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5 = Race(time: time5, raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))
        let race1s = Race(stringValue: "3:09:05", raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .km))
        let race2s = Race(stringValue: "1:10:59", raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km))
        let race3s = Race(stringValue: "0:50:00", raceDistance: RaceDistance(raceType: .km10, distanceUnit: .km))
        let race4s = Race(stringValue: "0:23:34", raceDistance: RaceDistance(raceType: .km5, distanceUnit: .km))
        let race5s = Race(stringValue: "10:00:00", raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .mile))
        XCTAssertEqual(race1, race1s)
        XCTAssertEqual(race2, race2s)
        XCTAssertEqual(race3, race3s)
        XCTAssertEqual(race4, race4s)
        XCTAssertEqual(race5, race5s)

        // inequality
        let race1unitDif = Race(stringValue: "3:09:05", raceDistance: RaceDistance(raceType: .marathon, distanceUnit: .mile))
        let race2unitDif = Race(stringValue: "1:10:59", raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
        let race3unitDif = Race(stringValue: "0:50:00", raceDistance: RaceDistance(raceType: .km10, distanceUnit: .mile))
        let race4unitDif = Race(stringValue: "0:23:34", raceDistance: RaceDistance(raceType: .km5, distanceUnit: .mile))
        let race5unitDif = Race(stringValue: "10:00:00", raceDistance: RaceDistance(raceType: .custom(100) , distanceUnit: .km))
        XCTAssert(race1 != race1unitDif)
        XCTAssert(race2 != race2unitDif)
        XCTAssert(race3 != race3unitDif)
        XCTAssert(race4 != race4unitDif)
        XCTAssert(race5 != race5unitDif)

        let raceCustomDif1 = Race(stringValue: "10:00:00", raceDistance: RaceDistance(raceType: .custom(80) , distanceUnit: .km))
        let raceCustomDif2 = Race(stringValue: "10:00:00", raceDistance: RaceDistance(raceType: .custom(80) , distanceUnit: .mile))
        XCTAssert(race5s != raceCustomDif1)
        XCTAssert(race5s != raceCustomDif2)
    }

    func testRaceDistanceCoefficient() {
        let distance1 = RaceDistance(raceType: .marathon, distanceUnit: .km)
        let distance2 = RaceDistance(raceType: .halfMarathon, distanceUnit: .km)
        let distance3 = RaceDistance(raceType: .km10, distanceUnit: .km)
        let distance4 = RaceDistance(raceType: .km5, distanceUnit: .km)
        let distance5 = RaceDistance(raceType: .custom(50), distanceUnit: .km)
        let distance1m = RaceDistance(raceType: .marathon, distanceUnit: .mile)
        let distance2m = RaceDistance(raceType: .halfMarathon, distanceUnit: .mile)
        let distance3m = RaceDistance(raceType: .km10, distanceUnit: .mile)
        let distance4m = RaceDistance(raceType: .km5, distanceUnit: .mile)
        let distance5m = RaceDistance(raceType: .custom(50), distanceUnit: .mile)

        XCTAssertTrue(distance1.coefficient == 42_195 && distance1.coefficient == distance1m.coefficient)
        XCTAssertTrue(distance2.coefficient == 21_097.5 && distance2.coefficient == distance2m.coefficient)
        XCTAssertTrue(distance3.coefficient == 10_000 && distance3.coefficient == distance3m.coefficient)
        XCTAssertTrue(distance4.coefficient == 5_000 && distance4.coefficient == distance4m.coefficient)
        XCTAssertTrue(distance5.coefficient == 50 * DistanceUnit.km.coefficient)
        XCTAssertTrue(distance5m.coefficient == 50 * DistanceUnit.mile.coefficient)

    }

    func testDistanceUnitCoefficient() {
        let km = DistanceUnit.km
        let mile = DistanceUnit.mile

        XCTAssertEqual(km.coefficient, 1000.0)
        XCTAssertEqual(mile.coefficient, 1609.34)
    }

}
