//
//  HelperFunctions.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-06.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

// Collection of mapping funtions for Rx work

public func toDoubleUsingCurrentLocale(_ input:String) -> Double? {
    let formatter = NumberFormatter()
    formatter.locale = NSLocale.current

    if let number = formatter.number(from: input) {
        return number.doubleValue
    }
    return nil
}
