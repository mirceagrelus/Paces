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

    var selectedPace: PublishRelay<PaceType> { get }
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

        paceTypeUpdated = selectedPace
            .map { selectedPace in (indexPath, selectedPace) }

    }

    public var inputs: ConfigurePaceTypeViewModelInputs { return self }
    public var outputs: ConfigurePaceTypeViewModelOutputs { return self }

    public let paceType: PaceType
    public let indexPath: IndexPath
    public var selectedPace: PublishRelay<PaceType> = PublishRelay()

    public var paceTypeUpdated: Observable<(IndexPath, PaceType)>// {
}

extension ConfigurePaceTypeViewModel: ConfigurePaceTypeViewModelInputs, ConfigurePaceTypeViewModelOutputs { }
