//
//  MainFlowController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import PacesKit

protocol MainFlowControllerDelegate: class {
    func mainFlowControllerDidFinish(_ flowController: MainFlowController)
}

class MainFlowController: UIViewController {

    weak var flowDelegate: MainFlowControllerDelegate?
    let mainNavigationController: UINavigationController =  {
        let theme = AppEnvironment.current.theme
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.tintColor = theme.navBarItemsTintColor
        navigationController.navigationBar.isTranslucent = true
        return navigationController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
    }

    override func viewDidAppear(_ animated: Bool) {
        print("resources: \(RxSwift.Resources.total)")
    }

    func start() {
        let pacesViewController = PacesViewController()
        pacesViewController.delegate = self

        mainNavigationController.viewControllers = [pacesViewController]
        add(childController: mainNavigationController)
    }

}

extension MainFlowController: PacesViewControllerDelegate {
    func pacesViewControllerShowSettings(_ pacesViewController: PacesViewController) {
        let vc = PacesViewController()
        vc.delegate = self

        self.mainNavigationController.pushViewController(vc, animated: true)


        print("resources: \(RxSwift.Resources.total)")
    }


}
