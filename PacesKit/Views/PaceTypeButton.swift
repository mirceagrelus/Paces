//
//  PaceTypeButton.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-26.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceTypeButton: UIButton {

    public var applyTextColor: () -> UIColor
    public var applySelectedTextColor: () -> UIColor
    public var applyBackgroundColor: () -> UIColor
    public var applySelectedBackgroundColor: () -> UIColor

    public let edgeInset: CGFloat = 10

    public init(applyTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColor,
                applySelectedTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColorSelected,
                applyBackgroundColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellBackgroundColor,
                applySelectedBackgroundColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellBackgroundColorSelected) {
        self.applyTextColor = applyTextColor
        self.applySelectedTextColor = applySelectedTextColor
        self.applyBackgroundColor = applyBackgroundColor
        self.applySelectedBackgroundColor = applySelectedBackgroundColor
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTextColor = { AppEnvironment.current.theme.controlCellTextColor }
        self.applySelectedTextColor = { AppEnvironment.current.theme.controlCellTextColorSelected }
        self.applyBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColor }
        self.applySelectedBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColorSelected }
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        setup()
        applyStyle()
    }

    func setup() {
        contentEdgeInsets = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
    }

    func applyStyle() {
        setTitleColor(applyTextColor(), for: .normal)
        setTitleColor(applySelectedTextColor(), for: .selected)
        setTitleColor(applySelectedTextColor(), for: .highlighted)

        setBackgroundColor(applyBackgroundColor(), for: .normal)
        setBackgroundColor(applySelectedBackgroundColor(), for: .selected)
        setBackgroundColor(applySelectedBackgroundColor(), for: .highlighted)
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

// MARK: - overrides
extension PaceTypeButton {
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
