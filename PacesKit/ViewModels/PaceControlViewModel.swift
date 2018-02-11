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

}

public protocol PaceControlViewModelOutputs {

}

public protocol PaceControlViewModelType {
    var inputs: PaceControlViewModelInputs { get }
    var outputs: PaceControlViewModelOutputs { get }
}

public class PaceControlViewModel: PaceControlViewModelType {
    public var inputs: PaceControlViewModelInputs { return self }
    public var outputs: PaceControlViewModelOutputs { return self }
}

extension PaceControlViewModel: PaceControlViewModelInputs, PaceControlViewModelOutputs { }
