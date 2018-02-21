//
//  ConversionControlLabel.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-21.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class ConversionControlLabel: UILabel {

    var applyTextColor: () -> UIColor
    var applySelectedTextColor: () -> UIColor

    var isSelected = false { didSet { self.applyStyle() } }

    public init(applyTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColor,
                applySelectedTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColorSelected) {
        self.applyTextColor = applyTextColor
        self.applySelectedTextColor = applySelectedTextColor
        super.init(frame: .zero)
        self.applyStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTextColor = { AppEnvironment.current.theme.controlCellTextColor }
        self.applySelectedTextColor = { AppEnvironment.current.theme.controlCellTextColorSelected }
        super.init(coder: aDecoder)
        self.applyStyle()
    }

    func applyStyle() {
        self.textColor = isSelected ? self.applySelectedTextColor() : self.applyTextColor()
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }
}


// MARK: - overrides
extension ConversionControlLabel {

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

