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
    //let navigationController: UINavigationController = UINavigationController()
    let mainNavigationController: UINavigationController =  {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.green

        // Do any additional setup after loading the view.
    }

    func start() {
        let pacesViewController = PacesViewController()

        mainNavigationController.viewControllers = [pacesViewController]
        add(childController: mainNavigationController)
    }

}
