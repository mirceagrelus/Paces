//
//  GradientView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

/**
    View with a gradient layer
 */
public class GradientView: UIView {
    private var gradientLayer : CAGradientLayer = CAGradientLayer()

    public init() {
        super.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func insertGradient(topToBottom: Bool, colorArray: [UIColor]) {
        if let sublayers = layer.sublayers {
            let _ = sublayers.filter { $0 is CAGradientLayer }.map { $0.removeFromSuperlayer() }
        }

        gradientLayer = CAGradientLayer()
        gradientLayer.colors = colorArray.map { $0.cgColor }
        if topToBottom {
            gradientLayer.locations = [0.0, 1.0]
        } else {
            //left to right
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        backgroundColor = .clear
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }

    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradientLayer.frame = self.bounds
    }

}
