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
    // source input pace to convert from
    var fromPaceType: PublishRelay<PaceType> { get }

    // the pace unit displayed by the control
    var toUnit: BehaviorRelay<PaceUnit> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // the control is considered the source of user input if it has the same unit as another control providing input
    var isSource: PublishRelay<Bool> { get }
}

public protocol PaceControlViewModelOutputs {
    // the calculated pace
    var pace: Observable<Pace> { get }

    // paceType to switch input to
    var switchUserInputPaceType: Observable<PaceType> { get }

    // control is selected in the UI
    var isSelected: Observable<Bool> { get }
}

public protocol PaceControlViewModelType {
    var inputs: PaceControlViewModelInputs { get }
    var outputs: PaceControlViewModelOutputs { get }
}

public class PaceControlViewModel: PaceControlViewModelType {

    init() {
        Observable
            .combineLatest(fromPaceType, toUnit) { (paceType, toUnit) -> Pace in
                return paceType.converted(to: toUnit)
            }
            .bind(to: _pace)
            .disposed(by: bag)

        isSelected = isSource
            .scan(false) { previous, isSource -> Bool in
                isSource ? !previous : false
            }
            .distinctUntilChanged()

        tapped
            .withLatestFrom(pace)
            .map { .pace($0) }
            .bind(to: _switchUserInputPaceType)
            .disposed(by: bag)
    }

    public var inputs: PaceControlViewModelInputs { return self }
    public var outputs: PaceControlViewModelOutputs { return self }

    public var fromPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var toUnit: BehaviorRelay<PaceUnit> =  BehaviorRelay(value: PaceUnit.minPerMile)
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var isSource: PublishRelay<Bool> = PublishRelay()

    fileprivate let _pace: PublishRelay<Pace> =  PublishRelay()
    public var pace: Observable<Pace> {
        return _pace.asObservable()
    }

    fileprivate let _switchUserInputPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var switchUserInputPaceType: Observable<PaceType> {
        return _switchUserInputPaceType.asObservable()
    }
    public var isSelected: Observable<Bool>

    private let bag = DisposeBag()
}

extension PaceControlViewModel: PaceControlViewModelInputs, PaceControlViewModelOutputs { }
