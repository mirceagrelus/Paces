//
//  PacesViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import PacesKit

public protocol PacesViewModelInputs {

}

public protocol PacesViewModelOutputs {

}

public protocol PacesViewModelType {
    var inputs: PacesViewModelInputs { get }
    var outputs: PacesViewModelOutputs { get }
}

public class PacesViewModel: PacesViewModelType {
    public var inputs: PacesViewModelInputs { return self }
    public var outputs: PacesViewModelOutputs { return self }

    init() {

    }
}

extension PacesViewModel: PacesViewModelInputs, PacesViewModelOutputs { }
