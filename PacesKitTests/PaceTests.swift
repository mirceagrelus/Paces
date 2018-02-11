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
    
    func testIsPacingUnit() {
        let pace1 = Pace(value: 0, unit: .minPerKm)
        let pace2 = Pace(value: 0, unit: .minPerMile)
        let pace3 = Pace(value: 0, unit: .kmPerHour)
        let pace4 = Pace(value: 0, unit: .milePerHour)

        let pacings = [pace1, pace2, pace3, pace4].map { $0.isPacingUnit }
        XCTAssertEqual(pacings, [true, true, false, false])
    }

    func testConvenieceConstructors() {
        let pace1 = Pace.minPerKm(seconds: 3 * 60 + 35)
        XCTAssertEqual(pace1.value, (3 * 60 + 35) / 60.0 )

        let pace2 = Pace.minPerMile(seconds: 9 * 60 + 00)
        XCTAssertEqual(pace2.value, (9 * 60 + 00) / 60.0 )
    }

    func testDisplayValue() {
        //let pace1 = Pace(value: 5 * 60 + 30, unit: .minPerKm)
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

    func testConverted() {
        let pace1 = Pace.minPerKm(seconds: 5 * 60 + 36)
        let pace1Conv1 = pace1.converted(to: .minPerMile)
        let pace1Conv2 = pace1.converted(to: .kmPerHour)
        let pace1Conv3 = pace1.converted(to: .milePerHour)
        let pace1Conv4 = pace1.converted(to: .minPerKm)
        XCTAssertEqual(pace1Conv1.displayValue, "9:01")
        XCTAssertEqual(pace1Conv2.displayValue, "10.7")
        XCTAssertEqual(pace1Conv3.displayValue, "6.7")
        XCTAssertEqual(pace1Conv4.displayValue, "5:36")

        let pace2 = Pace.minPerMile(seconds: 9 * 60 + 35)
        let pace2Conv1 = pace2.converted(to: .minPerKm)
        let pace2Conv2 = pace2.converted(to: .kmPerHour)
        let pace2Conv3 = pace2.converted(to: .milePerHour)
        XCTAssertEqual(pace2Conv1.displayValue, "5:57")
        XCTAssertEqual(pace2Conv2.displayValue, "10.1")
        XCTAssertEqual(pace2Conv3.displayValue, "6.3")

        let pace3 = Pace(value: 10, unit: .kmPerHour)
        let pace3Conv1 = pace3.converted(to: .minPerKm)
        let pace3Conv2 = pace3.converted(to: .minPerMile)
        let pace3Conv3 = pace3.converted(to: .milePerHour)
        XCTAssertEqual(pace3Conv1.displayValue, "6:00")
        XCTAssertEqual(pace3Conv2.displayValue, "9:39")
        XCTAssertEqual(pace3Conv3.displayValue, "6.2")

        let pace4 = Pace(value: 10.5, unit: .milePerHour)
        let pace4Conv1 = pace4.converted(to: .minPerKm)
        let pace4Conv2 = pace4.converted(to: .minPerMile)
        let pace4Conv3 = pace4.converted(to: .kmPerHour)
        XCTAssertEqual(pace4Conv1.displayValue, "3:33")
        XCTAssertEqual(pace4Conv2.displayValue, "5:43")
        XCTAssertEqual(pace4Conv3.displayValue, "16.9")
    }
    
}
