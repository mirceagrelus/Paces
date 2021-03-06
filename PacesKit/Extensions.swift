//
//  Extensions.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

extension UIView {
    public class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
        //return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    public class func fromNib<T: UIView>(named name:String) -> T {
        return Bundle(for: T.self).loadNibNamed(name, owner: nil, options: nil)![0] as! T
    }

    public class func fromMainNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

public extension Double {
    /// Rounds the double to decimal places value
    public func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


public extension Int {
    public func isEven() -> Bool {
        return self % 2 == 0
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
