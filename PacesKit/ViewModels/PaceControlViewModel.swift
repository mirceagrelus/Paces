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
    // the pace to display
    var pace: Observable<Pace> { get }

    // control is selected in the UI
    var isSelected: Observable<Bool> { get }

    // control tapped event
    var tapped: PublishRelay<Void> { get }

    // control tapped event
    var configureTapped: PublishRelay<Void> { get }
}

public protocol PaceControlViewModelOutputs {
}

public protocol PaceControlViewModelType {
    var inputs: PaceControlViewModelInputs { get }
    var outputs: PaceControlViewModelOutputs { get }
}

public class PaceControlViewModel: PaceControlViewModelType {

    init() { }

    init(pace: Observable<Pace>, isSelected: Observable<Bool>, tapped: PublishRelay<Void>, configureTapped: PublishRelay<Void>) {
        self.pace = pace
        self.isSelected = isSelected
        self.tapped = tapped
        self.configureTapped = configureTapped
    }

    public var inputs: PaceControlViewModelInputs { return self }
    public var outputs: PaceControlViewModelOutputs { return self }

    public var pace: Observable<Pace> =  Observable.empty()
    public var isSelected: Observable<Bool> = Observable.empty()
    public var tapped: PublishRelay<Void> = PublishRelay()
    public var configureTapped: PublishRelay<Void> = PublishRelay()


    public let bag = DisposeBag()
}

extension PaceControlViewModel: PaceControlViewModelInputs, PaceControlViewModelOutputs { }
