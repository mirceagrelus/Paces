//
//  ConfigurePaceTypeViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-03-01.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action

public protocol ConfigurePaceTypeViewModelInputs {
    // control paceType
    var paceType: PaceType? { get }

    // id of the control being configured
    var controlId: Int { get }

    //the selected PaceUnit to swith to
    var selectedPaceUnit: PublishRelay<PaceUnit> { get }

    // the selected raceType of the Race to swith to
    var selectedRaceType: PublishRelay<RaceType> { get }

    // the selected DistanceUnit of the Race to switch to
    var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit> { get }

    // delete tapped
    var selectedDelete: PublishRelay<Void> { get }
}

public protocol ConfigurePaceTypeViewModelOutputs {

    // Emits with the selected paceType
    var paceTypeUpdated: Observable<(Int, PaceType)> { get set }

    // Configuration has finished
    var configureFinished: PublishRelay<Void> { get }
}

// mark the protocol as having class semantics, otherwise viewModel didSet handler in ViewController gets called again when mutating the model,
// even though the model is a class.
public protocol ConfigurePaceTypeViewModelType: class {
    var inputs: ConfigurePaceTypeViewModelInputs { get }
    var outputs: ConfigurePaceTypeViewModelOutputs { get }

    // action to perform on delete
    var deleteAction: Action<Int, Void>? { get set }

    // action to perform PaceType update
    var updateAction: Action<(Int, PaceType), Void>? { get set }
}

public class ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelType {

    public init(paceType: PaceType?, controlId: Int) {
        self.paceType = paceType
        self.controlId = controlId

        // adding is a configuration with a nil PaceType. Consider a default distanceUnit of Km for Races
        // When editing use either the Race's or Pace's distance unit as default
        let raceDistanceUnit = paceType != nil ? paceType!.distanceUnit : DistanceUnit.km
        self.selectedRaceDistanceUnit = BehaviorRelay(value: raceDistanceUnit)

        // if editing a race type
        let initialRaceType: BehaviorRelay<RaceType?> = {
            if let existingPace = paceType,
                case let .race(race) = existingPace{
                return BehaviorRelay(value: race.raceDistance.raceType)
            }
            return BehaviorRelay(value: nil)
        }()

        // paceType from selected paceUnit
        let selectedPace = selectedPaceUnit
            .map { unit in  PaceType.pace(Pace(value: 0, unit: unit)) }

        // when switching to a race type automatically use the latest distance unit if present
        let raceTypePicked = selectedRaceType
            .withLatestFrom(selectedRaceDistanceUnit) { ($0, $1) }

        // when editing a Race allow for only picking distance unit also
        let distancePicked = selectedRaceDistanceUnit
            .takeWhile { _ in initialRaceType.value != nil }
            .withLatestFrom(initialRaceType) { ($1!, $0) }
            .skip(1)

        let selectedRace = Observable.merge(raceTypePicked, distancePicked)
            .map { (raceType, distanceUnit) in PaceType.race(Race(time: 0, raceDistance: RaceDistance(raceType: raceType, distanceUnit: distanceUnit))) }

        // update with either Pace or Race
        paceTypeUpdated = Observable.merge(
            selectedPace,
            selectedRace
            )
            .map { [paceType] in
                if let initialPace = paceType { return initialPace.converted(to: $0) }
                return $0
            }
            .map { selectedPace in (controlId, selectedPace) }
            .share(replay: 1, scope: .whileConnected)
    }

    public var deleteAction: Action<Int, Void>? {
        didSet {
            if let action = deleteAction {
                selectedDelete
                    .map { [paceType] _ in paceType}
                    .filter { $0 != nil }
                    .map { [controlId] _ in controlId }
                    .bind(to: action.inputs)
                    .disposed(by: bag)
            }
        }
    }

    public var updateAction: Action<(Int, PaceType), Void>? {
        didSet {
            if let action = updateAction {
                paceTypeUpdated
                    .take(1)
                    .bind(to: action.inputs)
                    .disposed(by: bag)
            }
        }
    }

    public var inputs: ConfigurePaceTypeViewModelInputs { return self }
    public var outputs: ConfigurePaceTypeViewModelOutputs { return self }

    public let paceType: PaceType?
    public let controlId: Int
    public var selectedPaceUnit: PublishRelay<PaceUnit> = PublishRelay()
    public var selectedRaceType: PublishRelay<RaceType> = PublishRelay()
    public var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit>
    public var selectedDelete: PublishRelay<Void> = PublishRelay()

    public var paceTypeUpdated: Observable<(Int, PaceType)>
    public var configureFinished: PublishRelay<Void> = PublishRelay()

    public let bag = DisposeBag()
}

extension ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelInputs, ConfigurePaceTypeViewModelOutputs { }
