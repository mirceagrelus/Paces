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

public enum ThemeType: String {
    case orangeRed
    case purpleBlue
    case solidRed
    case solidGreen
    case solidBlue
    case solidPurple
    case lightRed
    case lightOrange
    case lightGreen
    case lightBlue
    case lightPurple
    case lightPink
    case darkRed

    public var isDark: Bool {
        switch self {
        case .darkRed: return true
        default: return false
        }
    }

    public func theme() -> Theme {
        switch self {
        case .orangeRed: return ThemeOrangeRed(self)
        case .purpleBlue: return ThemePurpleBlue(self)
        case .solidRed: return ThemeSolidRed(self)
        case .solidGreen: return ThemeSolidGreen(self)
        case .solidBlue: return ThemeSolidBlue(self)
        case .solidPurple: return ThemeSolidPurple(self)
        case .lightRed: return ThemeLightRed(self)
        case .lightOrange: return ThemeLightOrange(self)
        case .lightGreen: return ThemeLightGreen(self)
        case .lightBlue: return ThemeLightBlue(self)
        case .lightPurple: return ThemeLightPurple(self)
        case .lightPink: return ThemeLightPink(self)
        case .darkRed: return ThemeDarkRed(self)
        }
    }

    public func toggle() -> ThemeType {
        switch self {
        case .orangeRed: return .purpleBlue
        case .purpleBlue: return .solidRed
        case .solidRed: return .solidGreen
        case .solidGreen: return .solidBlue
        case .solidBlue: return .solidPurple
        case .solidPurple: return .lightRed
        case .lightRed: return .lightOrange
        case .lightOrange: return .lightGreen
        case .lightGreen: return .lightBlue
        case .lightBlue: return .lightPurple
        case .lightPurple: return .lightPink
        case .lightPink: return .darkRed
        case .darkRed: return .orangeRed
        }
    }

}

public protocol Theme: class {
    var themeType: ThemeType { get }

    var textColor: UIColor { get }
    var backgroundColorGradient: [UIColor] { get }
    var backgroundColor: UIColor { get }

    var destructiveActionActiveColor: UIColor { get }
    var destructiveActionTextColor: UIColor { get }

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

    public var textColor = UIColor.white
    public var backgroundColorGradient = [#colorLiteral(red: 1, green: 0.3333333333, blue: 0, alpha: 1), .red]
    public var backgroundColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 0, alpha: 1)

    public var destructiveActionActiveColor = UIColor.black.withAlphaComponent(0.6)
    public var destructiveActionTextColor = UIColor.white

    public var navBarItemsTintColor = UIColor.black

    public var inputViewTextColor = UIColor.black
    public var inputViewBackgroundColor = UIColor.white

    public var controlCellTextColor = UIColor.white
    public var controlCellTextColorSelected = UIColor.black
    public var controlCellBackgroundColor = UIColor.black.withAlphaComponent(0.1)
    public var controlCellBackgroundColorSelected = UIColor.white
}

public class ThemePurpleBlue: Theme {
    public init(_ themeType: ThemeType) { self.themeType = themeType }
    public fileprivate(set) var themeType: ThemeType

    public var textColor = UIColor.white
    public var backgroundColorGradient = [#colorLiteral(red: 0.4705882353, green: 0, blue: 0.568627451, alpha: 1) , #colorLiteral(red: 0.168627451, green: 0, blue: 0.8823529412, alpha: 1)]
    public var backgroundColor = #colorLiteral(red: 0.4, green: 0, blue: 0.7176470588, alpha: 1)

    public var destructiveActionActiveColor = UIColor.black.withAlphaComponent(0.6)
    public var destructiveActionTextColor = UIColor.white

    public var navBarItemsTintColor = UIColor.black

    public var inputViewTextColor = UIColor.black
    public var inputViewBackgroundColor = UIColor.white

    public var controlCellTextColor = UIColor.white
    public var controlCellTextColorSelected = UIColor.black
    public var controlCellBackgroundColor = UIColor.black.withAlphaComponent(0.1)
    public var controlCellBackgroundColorSelected = UIColor.white
}

public class ThemeLightBase: Theme {
    public init(_ themeType: ThemeType) { self.themeType = themeType }
    public fileprivate(set) var themeType: ThemeType

    public var textColor = UIColor.black
    public var backgroundColorGradient = [UIColor.white, UIColor.white]
    public var backgroundColor = UIColor.white

    public var destructiveActionActiveColor = UIColor.black.withAlphaComponent(0.6)
    public var destructiveActionTextColor = UIColor.white

    public var navBarItemsTintColor = UIColor.black

    public var inputViewTextColor = UIColor.black
    public var inputViewBackgroundColor = UIColor.white

    public var controlCellTextColor = UIColor.black
    public var controlCellTextColorSelected = UIColor.white
    public var controlCellBackgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    public var controlCellBackgroundColorSelected = UIColor.red
}

public class ThemeSolidBase: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)

        textColor = UIColor.white
        backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1843137255, blue: 0.2705882353, alpha: 1)
        backgroundColorGradient = [backgroundColor, backgroundColor]

        destructiveActionTextColor = .white

        controlCellTextColor = .white
        controlCellTextColorSelected = .black
        controlCellBackgroundColor = UIColor.black.withAlphaComponent(0.1)
        controlCellBackgroundColorSelected = .white

    }
}

public class ThemeSolidRed: ThemeSolidBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1843137255, blue: 0.2705882353, alpha: 1)
        backgroundColorGradient = [backgroundColor, backgroundColor]
    }
}

public class ThemeSolidGreen: ThemeSolidBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        backgroundColor = #colorLiteral(red: 0, green: 0.7450980392, blue: 0.6117647059, alpha: 1)
        backgroundColorGradient = [backgroundColor, backgroundColor]
        controlCellBackgroundColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 0.5254901961, alpha: 1)
    }
}

public class ThemeSolidBlue: ThemeSolidBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        backgroundColor = #colorLiteral(red: 0.1450980392, green: 0.5882352941, blue: 0.8823529412, alpha: 1)
        backgroundColorGradient = [backgroundColor, backgroundColor]
        controlCellBackgroundColor = #colorLiteral(red: 0.09803921569, green: 0.4901960784, blue: 0.737254902, alpha: 1)
    }
}

public class ThemeSolidPurple: ThemeSolidBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.3215686275, blue: 0.7254901961, alpha: 1)
        backgroundColorGradient = [backgroundColor, backgroundColor]
        controlCellBackgroundColor = #colorLiteral(red: 0.5607843137, green: 0.2274509804, blue: 0.6941176471, alpha: 1)
    }
}


public class ThemeLightRed: ThemeLightBase {
    public override init(_ themeType: ThemeType) { super.init(themeType) }
}

public class ThemeLightOrange: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        controlCellBackgroundColorSelected = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
    }
}

public class ThemeLightGreen: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        controlCellBackgroundColorSelected = #colorLiteral(red: 0, green: 0.7411764706, blue: 0.6117647059, alpha: 1)
    }
}

public class ThemeLightBlue: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        controlCellBackgroundColorSelected = #colorLiteral(red: 0.1450980392, green: 0.5882352941, blue: 0.8823529412, alpha: 1)
    }
}

public class ThemeLightPurple: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        controlCellBackgroundColorSelected = #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8392156863, alpha: 1)
    }
}

public class ThemeLightPink: ThemeLightBase {
    public override init(_ themeType: ThemeType) {
        super.init(themeType)
        controlCellBackgroundColorSelected = #colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1)
    }
}

public class ThemeDarkBase: Theme {
    public init(_ themeType: ThemeType) { self.themeType = themeType }
    public fileprivate(set) var themeType: ThemeType

    public var textColor = UIColor.white
    public var backgroundColorGradient = [UIColor.black, UIColor.black]
    //public var backgroundColor: UIColor = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
    public var backgroundColor = #colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1)

    public var destructiveActionActiveColor = UIColor.white.withAlphaComponent(0.6)
    public var destructiveActionTextColor = UIColor.white

    public var navBarItemsTintColor = UIColor.white

    public var inputViewTextColor = UIColor.white
    public var inputViewBackgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

    public var controlCellTextColor = UIColor.white
    public var controlCellTextColorSelected = UIColor.white
    public var controlCellBackgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    public var controlCellBackgroundColorSelected = UIColor.red
}

public class ThemeDarkRed: ThemeDarkBase {
    public override init(_ themeType: ThemeType) { super.init(themeType) }
}
