//
//  ThemeView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-21.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

/**
    View that support theming for the background and border color
 */
public class ThemeView: UIView {

    public var applyBackgroundColor: () -> UIColor? { didSet { applyStyle() } }
    public var applyBorderColor: (() -> UIColor?)? { didSet { applyStyle() } }

    public init(color: @autoclosure @escaping () -> UIColor?) {
        applyBackgroundColor = color
        super.init(frame: .zero)
        applyStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        applyBackgroundColor = { UIColor.black }
        super.init(coder: aDecoder)
        applyBackgroundColor = { self.backgroundColor }
    }

    private func applyStyle() {
        backgroundColor = applyBackgroundColor()
        if let borderBlock = applyBorderColor {
            layer.borderColor = borderBlock()?.cgColor
        }
    }


    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

// MARK: - overrides
extension ThemeView {
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
