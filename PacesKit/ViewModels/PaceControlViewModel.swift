//
//  PaceControlViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol PaceControlViewModelInputs {
    //  source input pace to convert from
    var fromPace: PublishRelay<Pace> { get }

    // the unit paces are displayed in, by the control
    var toUnit: BehaviorRelay<PaceUnit> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // is the control considered the source of user input
    var isSource: PublishRelay<Bool> { get }
}

public protocol PaceControlViewModelOutputs {
    // the calculated pace
    var pace: Observable<Pace> { get }

    // unit to swithc input source to
    var switchUserInputPace: Observable<Pace> { get }
}

public protocol PaceControlViewModelType {
    var inputs: PaceControlViewModelInputs { get }
    var outputs: PaceControlViewModelOutputs { get }
}

public class PaceControlViewModel: PaceControlViewModelType {

    init() {

        Observable
            .combineLatest(fromPace, toUnit) { (pace, toUnit) -> Pace in
                pace.converted(to: toUnit)
            }
            .bind(to: paceSubject)
            .disposed(by: bag)

        tapped
            .withLatestFrom(pace)
            .bind(to: switchUserInputPaceRelay)
            .disposed(by: bag)
    }

    public var inputs: PaceControlViewModelInputs { return self }
    public var outputs: PaceControlViewModelOutputs { return self }

    public var fromPace: PublishRelay<Pace> =  PublishRelay()
    public var toUnit: BehaviorRelay<PaceUnit> =  BehaviorRelay(value: PaceUnit.minPerMile)
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var isSource: PublishRelay<Bool> = PublishRelay()

    fileprivate let paceSubject: PublishRelay<Pace> =  PublishRelay()
    public var pace: Observable<Pace> {
        return paceSubject.asObservable()
    }

    fileprivate let switchUserInputPaceRelay: PublishRelay<Pace> =  PublishRelay()
    public var switchUserInputPace: Observable<Pace> {
        return switchUserInputPaceRelay.asObservable()
    }

    private let bag = DisposeBag()
}

extension PaceControlViewModel: PaceControlViewModelInputs, PaceControlViewModelOutputs { }
