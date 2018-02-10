//
//  AppFlowViewModel.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol AppFlowViewModelInputs {
    var start: PublishRelay<Void> { get }

}

public protocol AppFlowViewModelOutputs {
    var gotoIntroController: Observable<Void> { get }
    var gotoMainController: Observable<Void> { get }

}

public protocol AppFlowViewModelType {
    var inputs: AppFlowViewModelInputs { get }
    var outputs: AppFlowViewModelOutputs { get }
}

public class AppFlowViewModel: AppFlowViewModelType {
    public var inputs: AppFlowViewModelInputs { return self }
    public var outputs: AppFlowViewModelOutputs { return self }

    public var start: PublishRelay<Void> = PublishRelay()

    fileprivate var gotoIntroControllerSubject: PublishSubject<Void> = PublishSubject()
    public var gotoIntroController: Observable<Void> {
        return gotoIntroControllerSubject.asObservable()
    }

    fileprivate var gotoMainControllerSubject: PublishSubject<Void> = PublishSubject()
    public var gotoMainController: Observable<Void> {
        return gotoMainControllerSubject.asObservable()
    }

    init() {
        _ = start
            .map { _ in
                true //introShown
            }
            .debug("start")
            .subscribe(onNext: { [weak self] (alreadyShownIntro) in
                alreadyShownIntro ? self?.gotoMainControllerSubject.onNext(()) : self?.gotoIntroControllerSubject.onNext(())
            })
    }

}

extension AppFlowViewModel: AppFlowViewModelInputs, AppFlowViewModelOutputs { }
