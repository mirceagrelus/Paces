//
//  ThemeLabel.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-21.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

/**
    Label that supports theming for the text color
 */
public class ThemeLabel: UILabel {

    var applyTextColor: () -> UIColor { didSet { self.applyStyle() } }

    public init(applyTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.textColor) {
        self.applyTextColor = applyTextColor
        super.init(frame: .zero)
        self.applyStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTextColor = { AppEnvironment.current.theme.textColor }
        super.init(coder: aDecoder)
        self.applyStyle()

    }

    private func applyStyle() {
        self.textColor = self.applyTextColor()
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }
}


// MARK: - overrides
extension ThemeLabel {

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
