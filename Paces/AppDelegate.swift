//
//  AppDelegate.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-09.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import PacesKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    fileprivate var viewModel: AppDelegateViewModelType = AppDelegateViewModel()
    var appFlowController: AppFlowController!
    let bag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Setup the environment, from storage
        AppEnvironment.replaceCurrentEnvironment(
            AppEnvironment.fromStorage(userDefaults: UserDefaults.standard)
        )

        // exit early when running Tests
        if let _ = NSClassFromString("XCTest") { return true }

        // A view controller should manage either sequence or UI, but not both.
        // FlowControllers manage sequences, regular controllers manage UI.
        // AppFlow is the root coordinator of sequences.
        appFlowController = AppFlowController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = appFlowController
        window?.makeKeyAndVisible()
        appFlowController.start()

        // sync iCloud
        viewModel.outputs.synchronizeUbiquitousStore
            .observeOnMain()
            .subscribe(onNext: { _ in
                _ = AppEnvironment.current.ubiquitousStore.synchronize()
            })
            .disposed(by: bag)

        viewModel.outputs.gotoWhatNew
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.appFlowController.goToWhatsNew()
            })
            .disposed(by: bag)

        viewModel.inputs.applicationDidFinishLaunching(application: application, launchOptions: launchOptions)
        return viewModel.outputs.applicationDidFinishLaunchingReturnValue
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

