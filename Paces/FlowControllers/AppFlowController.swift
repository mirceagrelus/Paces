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

    let bag = DisposeBag()
    var currentFlow: UIViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
    }

    func start() {
        // show main flow directly
        goToMainFlow()
    }

    public func goToWhatsNew() {
        let controller = EmptyViewController()
        //controller.flowDelegate = self

        // present What's new over existing UI
        currentFlow?.present(controller, animated: true, completion: nil)
    }

    public func goToMainFlow() {
        let mainFlowController = MainFlowController()
        mainFlowController.flowDelegate = self

        if let existing = currentFlow {
            remove(childController: existing)
        }
        add(childController: mainFlowController)
        currentFlow = mainFlowController
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
