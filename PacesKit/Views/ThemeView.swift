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

    var applyBackgroundColor: () -> UIColor? { didSet { self.applyStyle() } }
    var applyBorderColor: (() -> UIColor?)? { didSet { self.applyStyle() } }

    public init(color: @autoclosure @escaping () -> UIColor?) {
        applyBackgroundColor = color
        super.init(frame: .zero)
        self.applyStyle()
    }

//    public convenience init() {
//        self.init(color: Theme.current.baseBackgroundColor)
//    }

    public required init?(coder aDecoder: NSCoder) {
        applyBackgroundColor = { UIColor.black }
        super.init(coder: aDecoder)
        applyBackgroundColor = { self.backgroundColor }
    }

    private func applyStyle() {
        self.backgroundColor = self.applyBackgroundColor()
        if let borderBlock = self.applyBorderColor {
            self.layer.borderColor = borderBlock()?.cgColor
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
