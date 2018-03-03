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

//    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//    let blurEffectView: UIVisualEffectView = UIVisualEffectView(effect: nil)
    private let animator = UIViewPropertyAnimator(duration: 0.2, curve: UIViewAnimationCurve.linear, animations: nil)

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    deinit {
        print("DimView - deinit")
    }

    private func setup() {
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

//        alpha = 0.7
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
//        blurEffectView.contentView.addSubview(vibrancyEffectView)
//
//        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(blurEffectView)
//
//        AutoLayoutUtils.constrainView(vibrancyEffectView, equalToView: blurEffectView)
//        AutoLayoutUtils.constrainView(blurEffectView, equalToView: self)

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
            //self.blurEffectView.effect = self.blurEffect
        }
        animator.startAnimation()
    }

    public func hide(andRemove: Bool = false) {
        animator.addAnimations {
            self.alpha = 0
            //self.blurEffectView.effect = nil
        }
        if andRemove {
            animator.addCompletion { _ in
                self.removeFromSuperview()
            }
        }
        animator.startAnimation()
    }

}
