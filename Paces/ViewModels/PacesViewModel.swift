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
    // the string representation of the input pace value
    var inputValue: BehaviorRelay<String> { get }

    // the paceType configured for the input
    var inputPaceType: BehaviorRelay<PaceType> { get }

    // viewDidLoad event
    var viewDidLoad: PublishSubject<()> { get }

    // event for switching input to a new paceType
    var switchUserInputPaceType: BehaviorRelay<PaceType> { get }

    // pace type that is to be configured
    var configurePaceType: PublishRelay<(IndexPath, PaceType)> { get }
}

public protocol PacesViewModelOutputs {
    // the calculated pacing element from user input
    var paceType: Observable<PaceType> { get }

    // configured controls
    var paceControls: Observable<[ConversionControl]> { get }

    // show user input pane UI
    var showInput: Observable<Bool> { get }

    // data source of input for the picker view
    var inputDataSource: Observable<[[CustomStringConvertible]]> { get }

    // show configure pace view
    var goToConfigurePace: Observable<ConfigurePaceTypeViewModel> { get }
}

public protocol PacesViewModelType {
    var inputs: PacesViewModelInputs { get }
    var outputs: PacesViewModelOutputs { get }

    func bindControlModel() -> (PaceTypeControlViewModelType) -> ()
}

public class PacesViewModel: PacesViewModelType {

    init() {
        inputValue = BehaviorRelay(value: AppEnvironment.current.inputValue)
        inputPaceType = BehaviorRelay(value: AppEnvironment.current.inputPaceType)
        switchUserInputPaceType = BehaviorRelay(value: inputPaceType.value)
        //TODO: read paces config from AppEnvironment
        let envControls = [ConversionControl(sortOrder: 0, paceType: .pace(Pace(stringValue: "", unit: .minPerMile))),
                           ConversionControl(sortOrder: 1, paceType: .pace(Pace(stringValue: "", unit: .minPerKm))),
                           ConversionControl(sortOrder: 2, paceType: .pace(Pace(stringValue: "", unit: .kmPerHour))),
                           ConversionControl(sortOrder: 3, paceType: .pace(Pace(stringValue: "", unit: .milePerHour))),
                           ConversionControl(sortOrder: 4, paceType: .race(Race(time: 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km)) ))
        ]
        _paceControls = BehaviorRelay(value: envControls)

        // calculate new pace when user input value changes
        inputValue
            .withLatestFrom(inputPaceType) { value, inputPaceType -> PaceType in
                return inputPaceType.withUpdatedValue(value)
            }
            .debug("PaceType")
            .bind(to: _paceType)
            .disposed(by: bag)

        // share the latest computed pace, so new and reusable cells have an initial value
        paceType = _paceType.share(replay: 1, scope: .whileConnected)

        // switch to new input type
        switchUserInputPaceType
            .bind(to: inputPaceType)
            .disposed(by: bag)

        // update datasource for new type of input
        inputPaceType
            .map { paceType -> [[CustomStringConvertible]] in
                switch paceType {
                case .pace(let pace): return pace.unit.inputSource
                case .race(let race): return race.inputSource
                }
            }
            .bind(to: _inputDataSource)
            .disposed(by: bag)

        // update value for new type of input
        inputPaceType
            .map { $0.displayValue }
            .bind(to: inputValue)
            .disposed(by: bag)

        showInput = switchUserInputPaceType
            .scan([]) { lastSlice, val -> [PaceType] in
                let slice = (lastSlice + [val]).suffix(2)
                return Array(slice)
            }
            .filter { $0.count == 2 }
            .scan(true) { isShown, paceTypes -> Bool in
                let sameTapped = PaceType.equalUnits(lhs: paceTypes[0], rhs: paceTypes[1])
                return isShown ? !sameTapped : true
            }
            .startWith(true)

        goToConfigurePace = configurePaceType
            .map { (indexPath, paceType) -> ConfigurePaceTypeViewModel in
                 return ConfigurePaceTypeViewModel(paceType: paceType, indexPath: indexPath)
        }

        // store inputValue in Environment
        inputValue
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputValue: $0) })
            .disposed(by: bag)

        // store pace unit in Environment
        paceType
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputPaceType: $0) })
            .disposed(by: bag)
    }

    // closure used for binding the control model to the input model
    public func bindControlModel() -> (PaceTypeControlViewModelType) -> () {
        return { [weak self] controlModel in
            guard let strongSelf = self else { return }

            strongSelf.outputs.paceType
                .debug("control-pace")
                .bind(to: controlModel.inputs.fromPaceType)
                .disposed(by: controlModel.bag)

            controlModel.outputs.switchUserInputPaceType
                .debug("control-switchInputPace")
                .bind(to: strongSelf.inputs.switchUserInputPaceType)
                .disposed(by: controlModel.bag)

            strongSelf.inputs.switchUserInputPaceType
                .debug("control-switchUserInputPaceType")
                .withLatestFrom(controlModel.inputs.toPaceType)  { switchPaceType, toPaceType in
                    return PaceType.equalUnits(lhs: switchPaceType, rhs: toPaceType)
                }
                .bind(to: controlModel.inputs.isSource)
                .disposed(by: controlModel.bag)

            controlModel.outputs.configurePaceType
                .debug("control-configure")
                .bind(to: strongSelf.inputs.configurePaceType)
                .disposed(by: controlModel.bag)
        }
    }

    public var inputs: PacesViewModelInputs { return self }
    public var outputs: PacesViewModelOutputs { return self }

    public var inputValue: BehaviorRelay<String>
    public var inputPaceType: BehaviorRelay<PaceType>
    public var viewDidLoad: PublishSubject<()> = PublishSubject()
    public var switchUserInputPaceType: BehaviorRelay<PaceType>
    public var configurePaceType: PublishRelay<(IndexPath, PaceType)> = PublishRelay()

    fileprivate let _paceType: PublishRelay<PaceType> = PublishRelay()
    public var paceType: Observable<PaceType>

    fileprivate let _paceControls: BehaviorRelay<[ConversionControl]>
    public var paceControls: Observable<[ConversionControl]> {
        return _paceControls.asObservable()
    }
    public var showInput: Observable<Bool>

    fileprivate let _inputDataSource: BehaviorRelay<[[CustomStringConvertible]]> = BehaviorRelay(value: [])
    public var inputDataSource: Observable<[[CustomStringConvertible]]> {
        return _inputDataSource.asObservable()
    }

    public var goToConfigurePace: Observable<ConfigurePaceTypeViewModel> = Observable.never()

    private let bag = DisposeBag()
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }



