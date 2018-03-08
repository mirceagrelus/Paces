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

    // configured controls
     var paceControls: PublishRelay<[ConversionControl]> { get }

    // viewDidLoad event
    var viewDidLoad: PublishSubject<()> { get }

    // the id of the tapped control
    var tappedControl: PublishRelay<Int> { get }

    // PaceType with it's id that needs to be configured
    var configurePaceType: PublishRelay<(Int, PaceType)> { get }

    // add a new paceType
    var addPaceType: PublishRelay<Void> { get }
}

public protocol PacesViewModelOutputs {
    // the calculated pacing element from user input
    var paceType: Observable<PaceType> { get }

    // show user input pane UI
    var showInput: Observable<Bool> { get }

    // data source of input for the picker view
    var inputDataSource: Observable<[[CustomStringConvertible]]> { get }

    // selection state for controls (id, selected state)
    var controlSelections: Observable<[(Int, Bool)]> { get }

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

    var bag: DisposeBag { get }
}

public class PacesViewModel: PacesViewModelType {

    init() {
        inputValue = BehaviorRelay(value: AppEnvironment.current.inputValue)
        inputPaceType = BehaviorRelay(value: AppEnvironment.current.inputPaceType)

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

        // selected control
        tappedControl
            .withLatestFrom(selectedControl) { (tapped, selected) -> Int? in
                if let currentlySelected = selected,
                    tapped == currentlySelected {
                    return nil
                }
                return tapped
            }
            .debug("selectedControl")
            .bind(to: selectedControl)
            .disposed(by: bag)

        // selection state for controls
        selectedControl
            .withLatestFrom(paceControls) { (selected, controls) in
                controls.map { ($0.id, $0.id == selected) }
            }
            .bind(to: _controlSelections)
            .disposed(by: bag)

        showInput = selectedControl
            .map { $0 != nil }
            .debug("showInput")

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
            .withLatestFrom(initiallySelectedControl) { $1?.id }
            .take(1)
            .ignoreNil()
            .delay(0.5, scheduler: MainScheduler.instance)
            .bind(to: selectedControl)
            .disposed(by: bag)

    }

    // Action used for triggering the add of a PaceType control
    public var addPaceAction: CocoaAction {
        return CocoaAction { [weak self] _ -> Observable<Void> in
            self?.addPaceType.accept(())
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

            Observable
                .combineLatest(_self.outputs.controlSelections, controlModel.inputs.control) { (selection, control) in
                    selection
                        .filter { $0.0 == control.id }
                        .first
                }
                .ignoreNil()
                .map { $0.1 }
                .bind(to: controlModel.inputs.isSelected)
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
    public let paceControls: PublishRelay<[ConversionControl]> = PublishRelay()
    public var viewDidLoad: PublishSubject<()> = PublishSubject()
    public var tappedControl: PublishRelay<Int> = PublishRelay()
    public var configurePaceType: PublishRelay<(Int, PaceType)> = PublishRelay()
    public var addPaceType: PublishRelay<Void> = PublishRelay()

    fileprivate let _paceType: PublishRelay<PaceType> = PublishRelay()
    public var paceType: Observable<PaceType>

    public var showInput: Observable<Bool>

    fileprivate let _inputDataSource: BehaviorRelay<[[CustomStringConvertible]]> = BehaviorRelay(value: [])
    public var inputDataSource: Observable<[[CustomStringConvertible]]> {
        return _inputDataSource.asObservable()
    }
    fileprivate let _controlSelections: BehaviorRelay<[(Int, Bool)]> = BehaviorRelay(value: [])
    public var controlSelections: Observable<[(Int, Bool)]> {
        return _controlSelections.asObservable()
    }
    public var goToConfigurePace: Observable<ConfigurePaceTypeViewModel>
    public var goToAddPaceType: Observable<ConfigurePaceTypeViewModel>

    fileprivate let selectedControl: BehaviorRelay<Int?> = BehaviorRelay(value: nil)

    public let bag = DisposeBag()
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }



