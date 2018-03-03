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
    var paceType: PaceType { get }
    var indexPath: IndexPath { get }

    //the selected PaceUnit to swith to
    var selectedPaceUnit: PublishRelay<PaceUnit> { get }

    // the selected raceType of the Race to swith to
    var selectedRaceType: PublishRelay<RaceType> { get }

    // the selected DistanceUnit of the Race to switch to
    var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit> { get }
}

public protocol ConfigurePaceTypeViewModelOutputs {

    var paceTypeUpdated: Observable<(IndexPath, PaceType)> { get set }
}

public protocol ConfigurePaceTypeViewModelType {
    var inputs: ConfigurePaceTypeViewModelInputs { get }
    var outputs: ConfigurePaceTypeViewModelOutputs { get }
}

public class ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelType {

    public init(paceType: PaceType, indexPath: IndexPath) {
        self.paceType = paceType
        self.indexPath = indexPath

        // consider a default distanceUnit for Races, even for Paces (based on their distance unit)
        self.selectedRaceDistanceUnit = BehaviorRelay(value: paceType.distanceUnit)

        // if editing a race type
        let initialRaceType: BehaviorRelay<RaceType?> = {
            if case .race(let race) = paceType {
                return BehaviorRelay(value: race.raceDistance.raceType)
            }
            return BehaviorRelay(value: nil)
        }()

        // paceType from selected paceUnit
        let selectedPace = selectedPaceUnit
            .map { unit in  PaceType.pace(Pace(value: 0, unit: unit)) }

        // when switching to a race type automatically use the latest distance unit
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
            .map { selectedPace in (indexPath, selectedPace) }
    }

    public var inputs: ConfigurePaceTypeViewModelInputs { return self }
    public var outputs: ConfigurePaceTypeViewModelOutputs { return self }

    public let paceType: PaceType
    public let indexPath: IndexPath
    public var selectedPaceUnit: PublishRelay<PaceUnit> = PublishRelay()
    public var selectedRaceType: PublishRelay<RaceType> = PublishRelay()
    public var selectedRaceDistanceUnit: BehaviorRelay<DistanceUnit>

    public var paceTypeUpdated: Observable<(IndexPath, PaceType)>// {
}

extension ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelInputs, ConfigurePaceTypeViewModelOutputs { }
