//
//  PacesViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import PacesKit
import RxSwift
import RxCocoa

public protocol PacesViewModelInputs {
    // the string representation of the pace value
    var paceValue: BehaviorRelay<String> { get }

    // the unit paces should be displayed in.
    var paceUnit: BehaviorRelay<PaceUnit> { get }

    // viewDidLoad event
    var viewDidLoad: PublishSubject<()> { get }

    // the pace that the input UI has to provide input for
    var switchUserInputPace: BehaviorRelay<Pace> { get }
}

public protocol PacesViewModelOutputs {
    // calculated pace
    var pace: Observable<Pace> { get }

    // configured controls
    var paceControls: Observable<[ConversionControl]> { get }

    // the value of the last calculated pace
    var lastPace: Pace { get }

    // show user input UI
    var showInput: Observable<Bool> { get }
}

public protocol PacesViewModelType {
    var inputs: PacesViewModelInputs { get }
    var outputs: PacesViewModelOutputs { get }
}

public class PacesViewModel: PacesViewModelType {

    public var lastPace: Pace {
        return _pace.value
    }

    init() {
        paceValue = BehaviorRelay(value: AppEnvironment.current.inputPaceValue)
        paceUnit = BehaviorRelay(value: AppEnvironment.current.inputPaceUnit)
        switchUserInputPace = BehaviorRelay(value: Pace(stringValue: paceValue.value, unit: paceUnit.value))
        _pace = BehaviorRelay(value: switchUserInputPace.value)
        //TODO: read paces config from AppEnvironment
        let envControls = [ConversionControl(sortOrder: 0, unitType: .paceUnit(.minPerMile)),
                           ConversionControl(sortOrder: 1, unitType: .paceUnit(.minPerKm)),
                           ConversionControl(sortOrder: 2, unitType: .paceUnit(.kmPerHour)),
                           ConversionControl(sortOrder: 3, unitType: .paceUnit(.milePerHour)),
                           ConversionControl(sortOrder: 4, unitType: .raceDistance(26))]
        _paceControls = BehaviorRelay(value: envControls)

        // calculate new pace when user input pace value changes
        paceValue
            .withLatestFrom(paceUnit, resultSelector: { Pace(stringValue: $0, unit: $1) })
            .debug("pace")
            .bind(to: _pace)
            .disposed(by: bag)

        // switch to the new input unit
        switchUserInputPace
            .map { $0.unit }
            .bind(to: paceUnit)
            .disposed(by: bag)

        // switch to the new input value
        switchUserInputPace
            .map { $0.displayValue }
            .bind(to: paceValue)
            .disposed(by: bag)

        showInput = switchUserInputPace
            .scan([]) { lastSlice, val -> [Pace] in
                let slice = (lastSlice + [val]).suffix(2)
                return Array(slice)
            }
            .filter { $0.count == 2 }
            .scan(true) { isShown, paces -> Bool in
                let sameTapped = paces[0].unit == paces[1].unit
                return isShown ? !sameTapped : true
            }
            .startWith(true)

        // store paceValue in Environment
        paceValue
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputPaceValue: $0) })
            .disposed(by: bag)

        // store pace unit in Environment
        paceUnit
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputPaceUnit: $0) })
            .disposed(by: bag)
    }

    public var inputs: PacesViewModelInputs { return self }
    public var outputs: PacesViewModelOutputs { return self }

    public var paceValue: BehaviorRelay<String>
    public var paceUnit: BehaviorRelay<PaceUnit>
    public var viewDidLoad: PublishSubject<()> = PublishSubject()
    public var switchUserInputPace: BehaviorRelay<Pace>

    fileprivate let _pace: BehaviorRelay<Pace>
    public var pace: Observable<Pace> {
        return _pace.asObservable()
    }

    fileprivate let _paceControls: BehaviorRelay<[ConversionControl]>
    public var paceControls: Observable<[ConversionControl]> {
        return _paceControls.asObservable()
    }
    public var showInput: Observable<Bool>

    private let bag = DisposeBag()
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }



