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

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    func setup() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.insertGradient(topToBottom: true, colorArray: [UIColor.orange, UIColor.red])

        view.addSubview(gradientView)

        AutoLayoutUtils.constrainView(gradientView, equalToView: view)
    }

}
