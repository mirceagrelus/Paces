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
import Action

public protocol PacesViewModelInputs {
    // the string representation of the input pace value
    var inputValue: BehaviorRelay<String> { get }

    // the paceType configured for the input
    var inputPaceType: BehaviorRelay<PaceType> { get }

    // viewDidLoad event
    var viewDidLoad: PublishSubject<()> { get }

    // the control that was tapped
    var tappedControl: PublishRelay<ConversionControl> { get }

    // pace type that needs to be configured
    var configurePaceType: PublishRelay<(Int, PaceType)> { get }

    // add a new paceType
    var addPaceType: PublishRelay<Void> { get }
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

    // selection event rebroadcasted to all controls
    var controlSelection: Observable<ConversionControl> { get }

    // show configure pace UI
    var goToConfigurePace: Observable<ConfigurePaceTypeViewModel> { get }

    // show add pace UI
    var goToAddPaceType: Observable<ConfigurePaceTypeViewModel> { get }
}

public protocol PacesViewModelType {
    var inputs: PacesViewModelInputs { get }
    var outputs: PacesViewModelOutputs { get }

    var addPaceAction: CocoaAction { get }
    func bindControlModel() -> (PaceTypeControlViewModelType) -> ()
}

public class PacesViewModel: PacesViewModelType {

    init() {
        inputValue = BehaviorRelay(value: AppEnvironment.current.inputValue)
        inputPaceType = BehaviorRelay(value: AppEnvironment.current.inputPaceType)
        //TODO: read paces config from AppEnvironment
        let envControls = [ConversionControl(sortOrder: 0, paceType: .pace(Pace(stringValue: "", unit: .minPerMile))),
                           ConversionControl(sortOrder: 1, paceType: .pace(Pace(stringValue: "", unit: .minPerKm))),
                           ConversionControl(sortOrder: 2, paceType: .pace(Pace(stringValue: "", unit: .kmPerHour))),
                           ConversionControl(sortOrder: 3, paceType: .pace(Pace(stringValue: "", unit: .milePerHour))),
                           ConversionControl(sortOrder: 4, paceType: .race(Race(time: 0, raceDistance: RaceDistance(raceType: .halfMarathon, distanceUnit: .km)) ))
        ]
        _paceControls = BehaviorRelay(value: envControls)

        // share the latest computed pace
        paceType = _paceType.share(replay: 1, scope: .whileConnected)

        // calculate new pace for input value
        inputValue
            .withLatestFrom(inputPaceType) { value, inputPaceType -> PaceType in
                return inputPaceType.withUpdatedValue(value)
            }
            .debug("PaceType")
            .bind(to: _paceType)
            .disposed(by: bag)

        // update datasource for new type of input
        inputPaceType
            .map { paceType -> [[CustomStringConvertible]] in
                switch paceType {
                case .pace(let pace): return pace.unit.inputSource
                case .race(let race): return race.inputSource
                }
            }
            .debug("_inputDataSource")
            .bind(to: _inputDataSource)
            .disposed(by: bag)

        // update value for new type of input
        inputPaceType
            .debug("displayValue")
            .map { $0.displayValue }
            .bind(to: inputValue)
            .disposed(by: bag)

        // redistribute the tap event to all controls, so they can handle selection
        tappedControl
            .bind(to: _controlSelection)
            .disposed(by: bag)

        showInput = tappedControl
            .scan([]) { lastSlice, val -> [ConversionControl] in
                let slice = (lastSlice + [val]).suffix(2)
                return Array(slice)
            }
            .filter { $0.count == 2 }
            .scan(true) { isShown, controls -> Bool in
                let sameTapped = controls[0] == controls [1]
                return isShown ? !sameTapped : true
            }
            .startWith(true)

        goToConfigurePace = configurePaceType
            .map { (index, paceType) -> ConfigurePaceTypeViewModel in
                 return ConfigurePaceTypeViewModel(paceType: paceType, index: index)
        }

        goToAddPaceType = addPaceType
            .map { _ in ConfigurePaceTypeViewModel(paceType: nil, index: 0) }

        // store inputValue in Environment
        inputValue
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputValue: $0) })
            .disposed(by: bag)

        // store pace unit in Environment
        paceType
            .subscribe(onNext: { AppEnvironment.replaceCurrentEnvironment(inputPaceType: $0) })
            .disposed(by: bag)

        // select initial control on load
        let initiallySelectedControl = Observable
            .combineLatest(paceControls, inputPaceType) { (controls, lastPaceType) -> ConversionControl? in
                controls.first { PaceType.equalUnits(lhs: $0.paceType, rhs: lastPaceType) }
        }

        viewDidLoad
            .withLatestFrom(initiallySelectedControl)
            .take(1)
            .ignoreNil()
            .bind(to: _controlSelection)
            .disposed(by: bag)

    }

    // Action used for triggerign the add of a PaceType control
    public var addPaceAction: CocoaAction {
        return CocoaAction { [weak self] _ -> Observable<Void> in
            if let _self = self {
                return Observable.just(_self.addPaceType.accept(()))
            }
            return Observable.empty()
        }
    }

    // closure used for binding the control model to the input model
    public func bindControlModel() -> (PaceTypeControlViewModelType) -> () {
        return { [weak self] controlModel in
            guard let _self = self else { return }

            _self.outputs.paceType
                .bind(to: controlModel.inputs.fromPaceType)
                .disposed(by: controlModel.bag)

            controlModel.outputs.switchUserInputPaceType
                .bind(to: _self.inputs.inputPaceType)
                .disposed(by: controlModel.bag)

            controlModel.outputs.tappedControl
                .bind(to: _self.inputs.tappedControl)
                .disposed(by: controlModel.bag)

            _self.outputs.controlSelection
                .bind(to: controlModel.inputs.controlSelection)
                .disposed(by: controlModel.bag)

            controlModel.outputs.configurePaceType
                .bind(to: _self.inputs.configurePaceType)
                .disposed(by: controlModel.bag)
        }
    }

    public var inputs: PacesViewModelInputs { return self }
    public var outputs: PacesViewModelOutputs { return self }

    public var inputValue: BehaviorRelay<String>
    public var inputPaceType: BehaviorRelay<PaceType>
    public var viewDidLoad: PublishSubject<()> = PublishSubject()
    public var tappedControl: PublishRelay<ConversionControl> = PublishRelay()
    public var configurePaceType: PublishRelay<(Int, PaceType)> = PublishRelay()
    public var addPaceType: PublishRelay<Void> = PublishRelay()

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
    fileprivate let _controlSelection: PublishRelay<ConversionControl> = PublishRelay()
    public var controlSelection: Observable<ConversionControl> {
        return _controlSelection.asObservable()
    }

    public var goToConfigurePace: Observable<ConfigurePaceTypeViewModel>
    public var goToAddPaceType: Observable<ConfigurePaceTypeViewModel>

    private let bag = DisposeBag()
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }



