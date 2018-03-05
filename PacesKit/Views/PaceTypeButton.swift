//
//  PaceTypeButton.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-26.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

//@IBDesignable
public class PaceTypeButton: UIButton {

    var applyTextColor: () -> UIColor
    var applySelectedTextColor: () -> UIColor
    var applyBackgroundColor: () -> UIColor
    var applySelectedBackgroundColor: () -> UIColor

    let edgeInset: CGFloat = 10

//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            layer.cornerRadius = cornerRadius
//            layer.masksToBounds = cornerRadius > 0
//        }
//    }
//    @IBInspectable var borderWidth: CGFloat = 0 {
//        didSet {
//            layer.borderWidth = borderWidth
//        }
//    }
//    @IBInspectable var borderColor: UIColor? = UIColor.clear {
//        didSet {
//            layer.borderColor = borderColor?.cgColor
//        }
//    }

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
        applyStyle()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTextColor = { AppEnvironment.current.theme.controlCellTextColor }
        self.applySelectedTextColor = { AppEnvironment.current.theme.controlCellTextColorSelected }
        self.applyBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColor }
        self.applySelectedBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColorSelected }
        super.init(coder: aDecoder)
        commonInit()
        applyStyle()
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

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
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

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let currentGraphicsContext = UIGraphicsGetCurrentContext() {
            currentGraphicsContext.setFillColor(color.cgColor)
            currentGraphicsContext.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) }
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(colorImage, for: state)
        layer.masksToBounds = true
    }
}
