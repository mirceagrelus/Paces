//
//  AppDelegateViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import PacesKit

public protocol AppDelegateViewModelInputs {
    //var applicationDidEnterBackgroundSubject: PublishSubject<Void> { get }
}

public protocol AppDelegateViewModelOutputs {

}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs { get }
    var outputs: AppDelegateViewModelOutputs { get }
}

public class AppDelegateViewModel: AppDelegateViewModelType {

    init() {
    }

    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }

    //public var applicationDidEnterBackgroundSubject: PublishSubject<Void> = PublishSubject()
}

extension AppDelegateViewModel: AppDelegateViewModelInputs, AppDelegateViewModelOutputs { }
