//
//  AutoLayoutUtils.swift
//  Habits
//
//  Created by Mircea Grelus on 2018-01-27.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import UIKit

// Extend LayoutPriority to make it easier to use
// https://useyourloaf.com/blog/easier-swift-layout-priorities/
extension UILayoutPriority {
    public static func +(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue + rhs)
    }

    public static func -(lhs: UILayoutPriority, rhs: Float) -> UILayoutPriority {
        return UILayoutPriority(lhs.rawValue - rhs)
    }
}

public class AutoLayoutUtils {
    public class func constrainView(_ view: UIView, equalToView secondView: UIView){
//        view.topAnchor.constraint(equalTo: secondView.topAnchor).isActive = true
//        view.leadingAnchor.constraint(equalTo: secondView.leadingAnchor).isActive = true
//        view.trailingAnchor.constraint(equalTo: secondView.trailingAnchor).isActive = true
//        view.bottomAnchor.constraint(equalTo: secondView.bottomAnchor).isActive = true
        AutoLayoutUtils.constrainView(view, equalToView: secondView, inset: 0)
    }

    public class func constrainView(_ view: UIView, equalToView secondView: UIView, inset: CGFloat){
        view.topAnchor.constraint(equalTo: secondView.topAnchor, constant:inset).isActive = true
        view.leadingAnchor.constraint(equalTo: secondView.leadingAnchor, constant:inset).isActive = true
        view.trailingAnchor.constraint(equalTo: secondView.trailingAnchor, constant:-inset).isActive = true
        view.bottomAnchor.constraint(equalTo: secondView.bottomAnchor, constant:-inset).isActive = true
    }

    public class func constrainView(_ view: UIView, equalToGuide guide: UILayoutGuide, inset: CGFloat = 0){
        view.topAnchor.constraint(equalTo: guide.topAnchor, constant:inset).isActive = true
        view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant:inset).isActive = true
        view.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant:-inset).isActive = true
        view.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant:-inset).isActive = true
    }
}
