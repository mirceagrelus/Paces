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
    /// Call when the application finishes launching.
    func applicationDidFinishLaunching(application: UIApplication?, launchOptions: [AnyHashable: Any]?)
}

public protocol AppDelegateViewModelOutputs {
    /// The value to return from the delegate's `application:didFinishLaunchingWithOptions:` method.
    var applicationDidFinishLaunchingReturnValue: Bool { get }

    // Emits to synchronize iCloud on app launch.
    var synchronizeUbiquitousStore: Observable<Void> { get }

    // Emits when we should show the What's New screen
    var gotoWhatNew: Observable<Void> { get }
}

public protocol AppDelegateViewModelType {
    var inputs: AppDelegateViewModelInputs { get }
    var outputs: AppDelegateViewModelOutputs { get }
}

public class AppDelegateViewModel: AppDelegateViewModelType {

    init() {
        let appLaunched = applicationLaunchOptions
            .asObservable()
            .ignoreNil()
            .share(replay: 1, scope: .whileConnected)

        appLaunched
            .map { _, options in options?[UIApplicationLaunchOptionsKey.shortcutItem] == nil }
            .bind(to: _applicationDidFinishLaunchingReturnValue)
            .disposed(by: bag)

        synchronizeUbiquitousStore = appLaunched.map { _ in  }

        gotoWhatNew = appLaunched
            .take(1)
            .map { _ in }
            .filter { _ in AppEnvironment.current.whatsNewVersion > AppEnvironment.current.lastVersionWhatsNewShown }
            .filter { _ in false } //disable for now

        // if running UITests for taking AppStore Snaphots, switch to red theme
        appLaunched
            .filter { _ in ProcessInfo.processInfo.arguments.contains("AppStoreSnapshot") }
            .delay(1, scheduler: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { _ in
                AppEnvironment.replaceCurrentEnvironment(Environment(theme: ThemeType.orangeRed.theme()))
                notifyThemeDidChange()
            })
            .disposed(by: bag)

    }

    public var inputs: AppDelegateViewModelInputs { return self }
    public var outputs: AppDelegateViewModelOutputs { return self }

    fileprivate typealias ApplicationWithOptions = (application: UIApplication?, options: [AnyHashable: Any]?)
    fileprivate let applicationLaunchOptions = BehaviorRelay<ApplicationWithOptions?>(value: nil)
    public func applicationDidFinishLaunching(application: UIApplication?,
                                              launchOptions: [AnyHashable: Any]?) {
        self.applicationLaunchOptions.accept((application, launchOptions))
    }

    fileprivate let _applicationDidFinishLaunchingReturnValue = BehaviorRelay(value: true)
    public var applicationDidFinishLaunchingReturnValue: Bool {
        return _applicationDidFinishLaunchingReturnValue.value
    }
    public var synchronizeUbiquitousStore: Observable<Void>
    public var gotoWhatNew: Observable<Void>

    let bag = DisposeBag()

}

extension AppDelegateViewModel: AppDelegateViewModelInputs, AppDelegateViewModelOutputs { }
