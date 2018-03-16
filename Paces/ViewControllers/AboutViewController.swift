//
//  AboutViewController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-03-14.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import PacesKit
import RxSwift
import RxCocoa
import MessageUI
import SafariServices

protocol AboutViewControllerDelegate: class {
    func aboutViewControllerDidFinish(_ aboutController: AboutViewController)
}

class AboutViewController: UIViewController {
    weak var delegate: AboutViewControllerDelegate?
    @IBOutlet weak var scrollContentView: UIStackView!
    @IBOutlet weak var iconStackView: UIStackView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pacesTitleLabel: ThemeLabel!
    @IBOutlet weak var rateTheApp: PaceTypeButton!
    @IBOutlet weak var getInTouch: PaceTypeButton!
    @IBOutlet weak var rxSwiftLabel: ThemeLabel!
    @IBOutlet weak var twitterLink: ThemeButton!
    @IBOutlet weak var codexbitLink: ThemeButton!

    let bag = DisposeBag()
    let contentMarginInset: CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBindings()
    }

    func setup() {
        (view as? ThemeView)?.applyBackgroundColor = { AppEnvironment.current.theme.backgroundColor }
        scrollContentView.layoutMargins = UIEdgeInsets(top: contentMarginInset, left: 0, bottom: contentMarginInset, right: 0)
        scrollContentView.isLayoutMarginsRelativeArrangement = true
        iconImageView.tintColor = AppEnvironment.current.theme.textColor

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        pacesTitleLabel.text = "Paces \(appVersion ?? "")"
    }

    func setupBindings() {
        rateTheApp.rx.tap
            .subscribe(onNext: { _ in
                let appId = AppEnvironment.current.appConfig.appId
                guard let url = URL(string:"itms-apps://itunes.apple.com/app/id\(appId)?action=write-review") else { return }
                UIApplication.shared.open(url , options: [:], completionHandler: nil)
            })
            .disposed(by: bag)

        getInTouch.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.presentEmailComposer()
            })
            .disposed(by: bag)

        twitterLink.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let url = URL(string: "https://twitter.com/\(AppEnvironment.current.appConfig.twitter)") else { return }
                self?.presentSafari(url: url)
            })
            .disposed(by: bag)

        codexbitLink.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let url = URL(string: AppEnvironment.current.appConfig.website) else { return }
                self?.presentSafari(url: url)
            })
            .disposed(by: bag)

        let rxSwiftTap = UITapGestureRecognizer()
        rxSwiftLabel.addGestureRecognizer(rxSwiftTap)
        rxSwiftLabel.isUserInteractionEnabled = true
        rxSwiftTap.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let url = URL(string: "https://github.com/ReactiveX/RxSwift") else { return }
                self?.presentSafari(url: url)
            })
            .disposed(by: bag)

    }

    func presentEmailComposer() {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.setToRecipients([AppEnvironment.current.appConfig.contactEmail])
            var emailBody = "<b><u>Enter issue or comment:</u></b> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br /> <br />"
            emailBody.append("<hr /><span>Developer support information</span> <ul>")
            emailBody.append("<li> iOS version: \(UIDevice.current.systemVersion) </li>")
            emailBody.append("<li> Device Type: \(UIDevice.current.model) </li>")
            emailBody.append("<li> App Name: Paces </li>")
            let bundleInfo = Bundle.main.infoDictionary
            emailBody.append("<li> App version: \(bundleInfo?["CFBundleShortVersionString"] ?? "") (build \(bundleInfo?["CFBundleVersion"] ?? "" ))")
            emailBody.append("</ul> <hr />")
            composer.setMessageBody(emailBody, isHTML: true)

            self.present(composer, animated: true, completion: nil)

            composer.rx.didFinish
                .subscribe(onNext: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
                .disposed(by: bag)
        }
    }

    func presentSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)

    }

}


