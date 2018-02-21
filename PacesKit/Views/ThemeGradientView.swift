//
//  ThemeGradientView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-21.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

/**
    View with a gradient layer that supports theming
 */
public class ThemeGradientView: UIView {

    public var applyGradientColors: () -> [UIColor] { didSet { self.applyStyle() } }
    public var topToBottom: Bool = true { didSet { self.applyStyle() } }

    private var gradientLayer : CAGradientLayer = CAGradientLayer()

    public init(topToBottom: Bool = true, applyGradientColors: @escaping @autoclosure () -> [UIColor]) {
        self.topToBottom = topToBottom
        self.applyGradientColors = applyGradientColors
        super.init(frame: .zero)
        applyStyle()
    }

    required public init?(coder aDecoder: NSCoder) {
        self.applyGradientColors = { [UIColor.white, UIColor.black] }
        super.init(coder: aDecoder)
        applyStyle()
    }

    private func applyStyle() {
        self.insertGradient(colorArray: self.applyGradientColors())
    }

    private func insertGradient(colorArray: [UIColor]) {
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

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

// MARK: - overrides
extension ThemeGradientView {

    public override func didMoveToWindow() {
        if self.window != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(themeDidChangeNotification), name: NSNotification.Name.ThemeDidChange, object: nil)
        }
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        if window == nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ThemeDidChange, object: nil)
        }
    }
}
