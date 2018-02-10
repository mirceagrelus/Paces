//
//  AppFlowController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-09.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AppFlowController: UIViewController {

    let viewModel: AppFlowViewModelType = AppFlowViewModel()
    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.yellow
    }

    func start() {
        bindViewModel()

        viewModel.inputs.start.accept(())
    }

    func bindViewModel() {
        viewModel.outputs.gotoMainController
            .subscribe(onNext: { [weak self] in
                self?.startMain()
            })
            .disposed(by: bag)

        viewModel.outputs.gotoIntroController
            .subscribe(onNext: { [weak self] in
                self?.startIntro()
            })
            .disposed(by: bag)
    }

    func startIntro() {
//        let introFlowController = IntroFlowController()
//        introFlowController.delegate = self
//        add(childController: introFlowController)
//        introFlowController.start()
    }

    func startMain() {
        let mainFlowController = MainFlowController()
        mainFlowController.delegate = self
        add(childController: mainFlowController)
        mainFlowController.start()
    }


}

extension AppFlowController: MainFlowControllerDelegate {
    func mainFlowControllerDidFinish(_ flowController: MainFlowController) {
    }
}

// FlowController extensions
extension UIViewController {
    func add(childController: UIViewController) {
        addChildViewController(childController)
        view.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }

    func remove(childController: UIViewController) {
        childController.willMove(toParentViewController: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParentViewController()
    }
}
