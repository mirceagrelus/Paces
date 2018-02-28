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
    // the race to display
    var race: Observable<Race> { get }

    // control is selected in the UI
    var isSelected: Observable<Bool> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // control tapped event
    var configureTapped: PublishRelay<Void> { get }
}

public protocol DistanceControlViewModelOutputs {
}

public protocol DistanceControlViewModelType {
    var inputs: DistanceControlViewModelInputs { get }
    var outputs: DistanceControlViewModelOutputs { get }
}

public class DistanceControlViewModel: DistanceControlViewModelType {

    init() { }

    init(race: Observable<Race>, isSelected: Observable<Bool>, tapped: PublishRelay<Void>, configureTapped: PublishRelay<Void>) {
        self.race = race
        self.isSelected = isSelected
        self.tapped = tapped
        self.configureTapped = configureTapped
    }

    public var inputs: DistanceControlViewModelInputs { return self }
    public var outputs: DistanceControlViewModelOutputs { return self }

    public var race: Observable<Race> =  Observable.empty()
    public var isSelected: Observable<Bool> = Observable.empty()
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var configureTapped: PublishRelay<Void> = PublishRelay()


    public let bag = DisposeBag()
}

extension DistanceControlViewModel: DistanceControlViewModelInputs, DistanceControlViewModelOutputs { }
