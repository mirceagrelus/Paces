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

    public func setMailComposeDelegate(_ delegate: MFMailComposeViewControllerDelegate) -> Disposable {
        return RxMFMailComposeViewControllerDelegateProxy.installForwardDelegate(
            delegate,
            retainDelegate: false,
            onProxyForObject: self.base
        )
    }
}

