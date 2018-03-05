//
//  CustomDistanceTextField.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-05.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class CustomDistanceInput: UIView {

    var applyTextColor: () -> UIColor
    var applySelectedTextColor: () -> UIColor
    var applyBackgroundColor: () -> UIColor
    var applySelectedBackgroundColor: () -> UIColor
    var isSelected: Bool = false { didSet { applyStyle() } }

    let nameLabel: UILabel = UILabel()
    let distanceTextField: UITextField = UITextField()
    let labelFontSize: CGFloat = 18

    init(applyTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColor,
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
        nameLabel.font = UIFont.systemFont(ofSize: labelFontSize)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.isUserInteractionEnabled = false
        addSubview(nameLabel)


    }

    func applyStyle() {
        nameLabel.textColor = applyTextColor()

        self.backgroundColor = isSelected ? applySelectedBackgroundColor() : applyBackgroundColor()
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

extension CustomDistanceInput {

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
