//
//  Theme.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-21.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let ThemeDidChange = Notification.Name("ThemeDidChange")
}
public func notifyThemeDidChange() {
    NotificationCenter.default.post(name: Notification.Name.ThemeDidChange, object: nil)
}

public enum ThemeType: Int {
    case orangeRed
    case purpleBlue

    public func theme() -> Theme {
        switch self {
        case .orangeRed: return ThemeOrangeRed(self)
        case .purpleBlue: return ThemePurpleBlue(self)
        }
    }
}

public protocol Theme: class {
    var themeType: ThemeType { get }

    var textColor: UIColor { get }
    var backgroundColorGradient: [UIColor] { get }

    var navBarItemsTintColor: UIColor { get }

    var inputViewTextColor: UIColor { get }
    var inputViewBackgroundColor: UIColor { get }

    var controlCellTextColor: UIColor { get }
    var controlCellTextColorSelected: UIColor { get }
    var controlCellBackgroundColor: UIColor { get }
    var controlCellBackgroundColorSelected: UIColor { get }
}

public class ThemeOrangeRed: Theme {
    public init(_ themeType: ThemeType) { self.themeType = themeType }
    public fileprivate(set) var themeType: ThemeType

    public var textColor: UIColor = .white
    public var backgroundColorGradient: [UIColor] = [UIColor.orange, UIColor.red]

    public var navBarItemsTintColor: UIColor = .black

    public var inputViewTextColor: UIColor = .black
    public var inputViewBackgroundColor: UIColor = .white

    public var controlCellTextColor: UIColor = UIColor.white
    public var controlCellTextColorSelected: UIColor = UIColor.black
    public var controlCellBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.1)
    public var controlCellBackgroundColorSelected: UIColor = UIColor.white
}

public class ThemePurpleBlue: Theme {
    public init(_ themeType: ThemeType) { self.themeType = themeType }
    public fileprivate(set) var themeType: ThemeType

    public var textColor: UIColor = .white
    public var backgroundColorGradient: [UIColor] = [UIColor.purple, UIColor.blue]

    public var navBarItemsTintColor: UIColor = .black

    public var inputViewTextColor: UIColor = .black
    public var inputViewBackgroundColor: UIColor = .white

    public var controlCellTextColor: UIColor = .white
    public var controlCellTextColorSelected: UIColor = UIColor.black
    public var controlCellBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.1)
    public var controlCellBackgroundColorSelected: UIColor = UIColor.white
}
