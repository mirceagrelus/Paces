//
//  ConfiguredPace.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public struct ConversionControl {
    public var sortOrder: Int
    public var unitType: UnitType

    public enum UnitType {
        case paceUnit(PaceUnit)
        case raceDistance(Int)
    }

    public init(sortOrder: Int, unitType: UnitType) {
        self.sortOrder = sortOrder
        self.unitType = unitType

    }

    public static func orderSort(_ lhs: ConversionControl, _ rhs: ConversionControl) -> Bool {
        return (lhs.sortOrder) < (rhs.sortOrder)
    }
}
