//
//  AppDelegateViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public protocol AppDelegateViewModelInputs {

}

public protocol AppDelegateViewModelOutputs {

}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs { get }
    var outputs: AppDelegateViewModelOutputs { get }
}

public class AppDelegateViewModel: AppDelegateViewModelType {
    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }
}

extension AppDelegateViewModel: AppDelegateViewModelInputs, AppDelegateViewModelOutputs { }
