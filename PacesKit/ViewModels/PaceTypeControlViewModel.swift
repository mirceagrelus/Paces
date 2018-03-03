//
//  PaceTypeControlViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-27.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol PaceTypeControlViewModelInputs: class {
    // source input pace to convert from
    var fromPaceType: PublishRelay<PaceType> { get }

    // the pace type displayed by the control
    var toPaceType: BehaviorRelay<PaceType> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // control tapped event
    var configureTapped: PublishRelay<Void> { get }

    // the control is considered the source of user input if it has the same unit as another control providing input
    var isSource: PublishRelay<Bool> { get }

    // datasource index of current control
    var cellIndex: BehaviorRelay<IndexPath?> { get }
}

public protocol PaceTypeControlViewModelOutputs: class {
    // the calculated paceType
    var paceType: Observable<PaceType> { get }

    // paceType to switch input to
    var switchUserInputPaceType: Observable<PaceType> { get }

    // configure paceType for IndexPath element
    var configurePaceType: Observable<(IndexPath, PaceType)> { get }

    // control is selected in the UI
    var isSelected: Observable<Bool> { get }
}

public protocol PaceTypeControlViewModelType: class {
    var inputs: PaceTypeControlViewModelInputs { get }
    var outputs: PaceTypeControlViewModelOutputs { get }

    func configuredPaceViewModel() -> PaceControlViewModelType
    func configuredDistanceViewModel() -> DistanceControlViewModelType

    // determines the index of control in the datasource
    var cellIndexPath: (() -> IndexPath?)? { get set }

    var bag: DisposeBag { get }
}

public class PaceTypeControlViewModel: PaceTypeControlViewModelType {

    init() {
        Observable
            .combineLatest(fromPaceType, toPaceType) { (from, to) -> PaceType in
                return from.converted(to: to)
            }
            .bind(to: _paceType)
            .disposed(by: bag)

        isSelected = isSource
            .scan(false) { previous, isSource -> Bool in
                isSource ? !previous : false
            }
            .distinctUntilChanged()

        tapped
            .withLatestFrom(paceType)
            .bind(to: _switchUserInputPaceType)
            .disposed(by: bag)

        // when configuring deselect cell if it is selected
        configureTapped
            .withLatestFrom(isSelected)
            .filter { $0 }
            .map { _ in }
            .bind(to: tapped)
            .disposed(by: bag)

        configureTapped
            .map { [weak self] _ -> IndexPath? in
                return self?.cellIndexPath?()
            }
            .ignoreNil()
            .withLatestFrom(paceType) { ($0, $1)}
            .bind(to: _configurePaceType)
            .disposed(by: bag)

    }

    public func configuredPaceViewModel() -> PaceControlViewModelType {
        let pace = paceType
            .flatMap { paceType -> Observable<Pace> in
                if case .pace(let pace) = paceType {
                    return Observable.of(pace)
                }
                return Observable.empty()
            }
            .share(replay: 1, scope: .whileConnected)

        let controlViewModel = PaceControlViewModel(pace: pace, isSelected: isSelected, tapped: tapped, configureTapped: configureTapped)
        return controlViewModel
    }

    public func configuredDistanceViewModel() -> DistanceControlViewModelType {
        let race = paceType
            .flatMap { (paceType) -> Observable<Race> in
                if case .race(let race) = paceType {
                    return Observable.of(race)
                }
                return Observable.empty()
            }
            .share(replay: 1, scope: .whileConnected)

        let controlViewModel = DistanceControlViewModel(race: race, isSelected: isSelected, tapped: tapped, configureTapped: configureTapped)
        return controlViewModel
    }

    public var inputs: PaceTypeControlViewModelInputs { return self }
    public var outputs: PaceTypeControlViewModelOutputs { return self }

    public var fromPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var toPaceType: BehaviorRelay<PaceType> =  BehaviorRelay(value: PaceType.pace(Pace(value: 0, unit: .minPerMile)))
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var configureTapped: PublishRelay<Void> = PublishRelay()
    public var isSource: PublishRelay<Bool> = PublishRelay()
    public var cellIndex: BehaviorRelay<IndexPath?> = BehaviorRelay(value: nil)

    fileprivate let _paceType: PublishRelay<PaceType> =  PublishRelay()
    public var paceType: Observable<PaceType> {
        return _paceType.asObservable()
    }
    fileprivate let _switchUserInputPaceType: PublishRelay<PaceType> =  PublishRelay()
    public var switchUserInputPaceType: Observable<PaceType> {
        return _switchUserInputPaceType.asObservable()
    }

    fileprivate let _configurePaceType: PublishRelay<(IndexPath, PaceType)> = PublishRelay()
    public var configurePaceType: Observable<(IndexPath, PaceType)> {
        return _configurePaceType.asObservable()
    }

    public var isSelected: Observable<Bool>

    public weak var collectionCell: PaceTypeControlCollectionViewCell?
    public var cellIndexPath: (() -> IndexPath?)?

    public let bag = DisposeBag()
}

extension PaceTypeControlViewModel: PaceTypeControlViewModelInputs, PaceTypeControlViewModelOutputs { }



