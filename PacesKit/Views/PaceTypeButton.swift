//
//  PaceTypeButton.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-26.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

@IBDesignable
public class PaceTypeButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? = UIColor.clear {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        //view = PaceTypeButton.fromNib()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    public override func awakeFromNib() {
        self.setBackgroundColor(UIColor.green, for: UIControlState.normal)
        self.setBackgroundColor(UIColor.red, for: UIControlState.selected)
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
