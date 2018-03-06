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

public protocol ConfigurePaceTypeViewModelInputs {
    // control paceType
    var paceType: PaceType? { get }

    // index of the control in the datasource
    var index: Int { get }

    //the selected PaceUnit to swith to
    var selectedPaceUnit: PublishRelay<PaceUnit> { get }

    // the selected raceType of the Race to swith to
    var selectedRaceType: PublishRelay<RaceType> { get }

    // the selected DistanceUnit of the Race to switch to
    var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit> { get }
}

public protocol ConfigurePaceTypeViewModelOutputs {

    // Emits with the selected paceType
    var paceTypeUpdated: Observable<(Int, PaceType)> { get set }

    // Configuration has finished
    var configureFinished: PublishRelay<Void> { get }
}

public protocol ConfigurePaceTypeViewModelType {
    var inputs: ConfigurePaceTypeViewModelInputs { get }
    var outputs: ConfigurePaceTypeViewModelOutputs { get }
}

public class ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelType {

    public init(paceType: PaceType?, index: Int) {
        self.paceType = paceType
        self.index = index

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

        //let selectedRace = pickRaceType.amb(pickDistance)
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
            .map { selectedPace in (index, selectedPace) }
    }

    public var inputs: ConfigurePaceTypeViewModelInputs { return self }
    public var outputs: ConfigurePaceTypeViewModelOutputs { return self }

    public let paceType: PaceType?
    public let index: Int
    public var selectedPaceUnit: PublishRelay<PaceUnit> = PublishRelay()
    public var selectedRaceType: PublishRelay<RaceType> = PublishRelay()
    public var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit>

    public var paceTypeUpdated: Observable<(Int, PaceType)>
    public var configureFinished: PublishRelay<Void> = PublishRelay()
}

extension ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelInputs, ConfigurePaceTypeViewModelOutputs { }
