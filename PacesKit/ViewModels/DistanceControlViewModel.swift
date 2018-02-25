//
//  DistanceControlViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-23.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol DistanceControlViewModelInputs {
    // source input pace to convert from
    var fromPaceType: PublishRelay<PaceType> { get }

    // the race distance displayed by the control
    var toRaceDistance: BehaviorRelay<RaceDistance> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // the control is considered the source of user input if it has the same unit as another control providing input
    var isSource: PublishRelay<Bool> { get }
}

public protocol DistanceControlViewModelOutputs {
    // the calculated race
    var race: Observable<Race> { get }

    // paceType to switch input to
    var switchUserInputPaceType: Observable<PaceType> { get }

    // control is selected in the UI
    var isSelected: Observable<Bool> { get }
}

public protocol DistanceControlViewModelType {
    var inputs: DistanceControlViewModelInputs { get }
    var outputs: DistanceControlViewModelOutputs { get }
}

public class DistanceControlViewModel: DistanceControlViewModelType {

    init() {
        Observable
            .combineLatest(fromPaceType, toRaceDistance) { (paceType, raceDistance) -> Race in
                return paceType.converted(to: raceDistance)
            }
            .bind(to: _race)
            .disposed(by: bag)

        isSelected = isSource
            .scan(false) { previous, isSource -> Bool in
                isSource ? !previous : false
            }
            .distinctUntilChanged()

        tapped
            .withLatestFrom(race)
            .map { .race($0) }
            .bind(to: _switchUserInputPaceType)
            .disposed(by: bag)
    }

    public var inputs: DistanceControlViewModelInputs { return self }
    public var outputs: DistanceControlViewModelOutputs { return self }

    public var fromPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var toRaceDistance: BehaviorRelay<RaceDistance> =  BehaviorRelay(value: RaceDistance(raceType: .halfMarathon, distanceUnit: .mile))
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var isSource: PublishRelay<Bool> = PublishRelay()

    fileprivate let _race: PublishRelay<Race> =  PublishRelay()
    public var race: Observable<Race> {
        return _race.asObservable()
    }

    fileprivate let _switchUserInputPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var switchUserInputPaceType: Observable<PaceType> {
        return _switchUserInputPaceType.asObservable()
    }
    public var isSelected: Observable<Bool>

    private let bag = DisposeBag()
}

extension DistanceControlViewModel: DistanceControlViewModelInputs, DistanceControlViewModelOutputs { }
