//
//  PacesViewController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import PacesKit

class PacesViewController: UIViewController {

    let gradientView: GradientView = GradientView()
    let paceContentView: UIView = UIView()
    let paceControl: PaceControlView  = PaceControlView.fromNib()

    let paceControlHeight: CGFloat = 200

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.insertGradient(topToBottom: true, colorArray: [UIColor.orange, UIColor.red])
        view.addSubview(gradientView)

        paceContentView.translatesAutoresizingMaskIntoConstraints = false
        //paceContentView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        gradientView.addSubview(paceContentView)

        paceControl.translatesAutoresizingMaskIntoConstraints = false
        paceContentView.addSubview(paceControl)

        AutoLayoutUtils.constrainView(gradientView, equalToView: view)
        AutoLayoutUtils.constrainView(paceContentView, equalToGuide: gradientView.safeAreaLayoutGuide)

        NSLayoutConstraint.activate([
            paceControl.leadingAnchor.constraint(equalTo: paceContentView.layoutMarginsGuide.leadingAnchor),
            paceControl.trailingAnchor.constraint(equalTo: paceContentView.layoutMarginsGuide.trailingAnchor),
            paceControl.topAnchor.constraint(equalTo: paceContentView.layoutMarginsGuide.topAnchor),
            paceControl.heightAnchor.constraint(equalToConstant: paceControlHeight)
            ])
    }

}
