//
//  ThemeButton.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-11.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class ThemeButton: UIButton {

    var applyTintColor: () -> UIColor { didSet { applyStyle() } }
    var applyBackgroundColor: () -> UIColor { didSet { applyStyle() } }

    public init(applyTintColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.textColor,
                applyBackgroundColor: @escaping @autoclosure () -> UIColor = UIColor.clear) {
        self.applyTintColor = applyTintColor
        self.applyBackgroundColor = applyBackgroundColor
        super.init(frame: .zero)
        applyStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTintColor = { AppEnvironment.current.theme.textColor }
        self.applyBackgroundColor = { UIColor.clear }
        super.init(coder: aDecoder)
        applyStyle()

    }

    public func applyStyle() {
        tintColor = applyTintColor()
        setBackgroundColor(applyBackgroundColor(), for: .normal)
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

// MARK: - overrides
extension ThemeButton {
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
