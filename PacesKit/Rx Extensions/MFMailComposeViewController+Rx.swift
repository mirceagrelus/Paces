//
//  MFMailComposeViewController+Rx.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-15.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import MessageUI
import RxSwift
import RxCocoa

public class RxMFMailComposeViewControllerDelegateProxy: DelegateProxy<MFMailComposeViewController, MFMailComposeViewControllerDelegate>, DelegateProxyType, MFMailComposeViewControllerDelegate
{
    public static func currentDelegate(for object: MFMailComposeViewController) -> MFMailComposeViewControllerDelegate? {
        return object.mailComposeDelegate
    }

    public static func setCurrentDelegate(_ delegate: MFMailComposeViewControllerDelegate?, to object: MFMailComposeViewController) {
        object.mailComposeDelegate = delegate
    }

    public weak private(set) var mailComposeViewController: MFMailComposeViewController?

    public init(mailComposeViewController: ParentObject) {
        self.mailComposeViewController = mailComposeViewController
        super.init(parentObject: mailComposeViewController, delegateProxy: RxMFMailComposeViewControllerDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxMFMailComposeViewControllerDelegateProxy(mailComposeViewController: $0) }
    }

}

extension Reactive where Base: MFMailComposeViewController {
    public var mailComposeDelegate: DelegateProxy<MFMailComposeViewController, MFMailComposeViewControllerDelegate> {
        return RxMFMailComposeViewControllerDelegateProxy.proxy(for: base)
    }

    public var didFinish: Observable<MFMailComposeResult> {
        return mailComposeDelegate
            .methodInvoked(#selector(MFMailComposeViewControllerDelegate.mailComposeController(_:didFinishWith:error:)))
            .map { parameters in
                return MFMailComposeResult(rawValue: parameters[1] as! Int) ?? MFMailComposeResult.failed
        }
    }

}

