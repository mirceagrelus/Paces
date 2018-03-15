//
//  Storyboard.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-14.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public enum Storyboard: String {
    case AboutViewController

    public var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    public func instantiate<VC: UIViewController>() -> VC {
        switch self {
        case .AboutViewController:
            guard let vc = mainStoryboard.instantiateViewController(withIdentifier: self.rawValue) as? VC else { fatalError("Couldn't instantiate \(self.rawValue) from Main Storyboard") }
            return vc
        }
    }
}

