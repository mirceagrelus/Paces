//
//  PaceControlViewModelTests.swift
//  PacesKitTests
//
//  Created by Mircea Grelus on 2018-02-11.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import RxTest
@testable import PacesKit

class PaceControlViewModelTests: XCTestCase {

    let testScheduler: TestScheduler = TestScheduler(initialClock: 0)

    let vm: PaceControlViewModelType = PaceControlViewModel()
    let bag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConversion() {
        let convertedPace = testScheduler.createObserver(Pace.self)
        vm.outputs.pace.bind(to: convertedPace).disposed(by: bag)

        // start with 10 kph
        let inputPace = Pace(value: 10, unit: .kmPerHour)
        vm.inputs.fromPace.accept(inputPace)
        vm.inputs.toUnit.accept(PaceUnit.minPerKm)

        //  => 6:00 min/km
        var expected = Pace.minPerKm(seconds: 6 * 60)
        var received = convertedPace.events.last.map { $0.value }?.element
        XCTAssertEqual(expected.displayValue, received?.displayValue);

        //  => 6.2 mph
        vm.inputs.toUnit.accept(PaceUnit.milePerHour)
        expected = Pace(value: 6.2, unit: .milePerHour)
        received = convertedPace.events.last.map { $0.value }?.element
        XCTAssertEqual(expected.displayValue, received?.displayValue);

        //  => 9:39 min/mile
        vm.inputs.toUnit.accept(PaceUnit.minPerMile)
        expected = Pace.minPerMile(seconds: 9 * 60 + 39)
        received = convertedPace.events.last.map { $0.value }?.element
        XCTAssertEqual(expected.displayValue, received?.displayValue);

        // change input value
        // 10 min/mile => 6:13 min/km
        vm.inputs.fromPace.accept(Pace.minPerMile(seconds: 10 * 60))
        vm.inputs.toUnit.accept(PaceUnit.minPerKm)
        expected = Pace.minPerKm(seconds: 6*60 + 13)
        received = convertedPace.events.last.map { $0.value }?.element
        XCTAssertEqual(expected.displayValue, received?.displayValue);

        // change value
        // 9 min/mile => 5:36 min/km
        vm.inputs.fromPace.accept(Pace.minPerMile(seconds: 9*60))
        expected = Pace.minPerKm(seconds: 5*60 + 36)
        received = convertedPace.events.last.map { $0.value }?.element
        XCTAssertEqual(expected.displayValue, received?.displayValue);

    }

    
}
