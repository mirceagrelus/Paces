//
//  MainFlowController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import PacesKit
import RxSwift
import RxCocoa

protocol MainFlowControllerDelegate: class {
    func mainFlowControllerDidFinish(_ flowController: MainFlowController)
}

class MainFlowController: UIViewController {

    let bag = DisposeBag()
    weak var flowDelegate: MainFlowControllerDelegate?
    let mainNavigationController: UINavigationController =  {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.navigationBar.isTranslucent = true
        return navigationController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyle()
        NotificationCenter.default.rx.notification(Notification.Name.ThemeDidChange)
            .observeOnMain()
            .subscribe(onNext: { [weak self] _ in
                self?.applyStyle()
            })
        .disposed(by: bag)
    }

    func start() {
        let pacesViewController = PacesViewController()
        pacesViewController.delegate = self

        mainNavigationController.viewControllers = [pacesViewController]
        add(childController: mainNavigationController)
    }

    func applyStyle() {
        mainNavigationController.navigationBar.tintColor = AppEnvironment.current.theme.navBarItemsTintColor
        mainNavigationController.navigationBar.barStyle = AppEnvironment.current.theme.themeType.isDark ? .blackTranslucent : UIBarStyle.default
    }

}

extension MainFlowController: PacesViewControllerDelegate {
    func pacesViewControllerShowAbout(_ pacesViewController: PacesViewController) {
        guard let about = Storyboard.AboutViewController.instantiate() as? AboutViewController else { return }
        about.delegate = self

        self.mainNavigationController.pushViewController(about, animated: true)
    }

}

extension MainFlowController: AboutViewControllerDelegate {
    func aboutViewControllerDidFinish(_ aboutController: AboutViewController) {
        mainNavigationController.popViewController(animated: true)
    }


}
