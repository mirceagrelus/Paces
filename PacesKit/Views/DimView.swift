//
//  DimView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-02.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift

public class DimView: UIView {

    public let tapped: PublishSubject<Void> = PublishSubject()
    public let bag = DisposeBag()
    private let animator = UIViewPropertyAnimator(duration: 0.2, curve: UIViewAnimationCurve.linear, animations: nil)

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .map { _ in }
            .bind(to: tapped)
            .disposed(by: bag)
    }

    public func show() {
        animator.addAnimations {
            self.alpha = 1.0
        }
        animator.startAnimation()
    }

    public func hide(andRemove: Bool = false) {
        animator.addAnimations {
            self.alpha = 0
        }
        if andRemove {
            animator.addCompletion { _ in
                self.removeFromSuperview()
            }
        }
        animator.startAnimation()
    }

}
