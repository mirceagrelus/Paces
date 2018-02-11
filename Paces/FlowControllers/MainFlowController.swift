//
//  MainFlowController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

protocol MainFlowControllerDelegate: class {
    func mainFlowControllerDidFinish(_ flowController: MainFlowController)
}

class MainFlowController: UIViewController {

    weak var delegate: MainFlowControllerDelegate?
    let mainNavigationController: UINavigationController =  {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.green

    }

    func start() {
        let pacesViewController = PacesViewController()

        mainNavigationController.viewControllers = [pacesViewController]
        add(childController: mainNavigationController)
    }

}
