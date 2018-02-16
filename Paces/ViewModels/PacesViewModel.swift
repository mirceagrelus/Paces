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

    // emits the units that were archived on first load, and then terminates
    var archivedUnits: Observable<[PaceUnit]> { get set }
}

public protocol PacesViewModelType {
    var inputs: PacesViewModelInputs { get }
    var outputs: PacesViewModelOutputs { get }
}

public class PacesViewModel: PacesViewModelType {

    init() {
        paceValue = BehaviorRelay(value: AppEnvironment.current.inputPaceValue)
        paceUnit = BehaviorRelay(value: AppEnvironment.current.inputPaceUnit)
        switchUserInputPace = BehaviorRelay(value: Pace(stringValue: paceValue.value, unit: paceUnit.value))

        archivedUnits = viewDidLoad
            .take(1)
            .map { _ in
                //TODO: read data from AppEnvironment
                return [ PaceUnit.minPerMile, PaceUnit.minPerKm, PaceUnit.kmPerHour ]
            }
            .share(replay: 1, scope: .whileConnected)

        // calculate new pace when user input pace value changes
        paceValue
            .withLatestFrom(paceUnit, resultSelector: { Pace(stringValue: $0, unit: $1) })
            .debug("pace")
            .bind(to: paceSubject)
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

    fileprivate let paceSubject: PublishRelay<Pace> =  PublishRelay()
    public var pace: Observable<Pace> {
        return paceSubject.asObservable()
    }

    public var archivedUnits: Observable<[PaceUnit]>

    private let bag = DisposeBag()
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }
