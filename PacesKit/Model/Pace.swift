//
//  Pace.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public struct Pace {
    public var value: Double
    public let unit: PaceUnit

    public var isPacingUnit: Bool {
        return unit.isPacingUnit
    }

    public var isSpeedUnit: Bool {
        return unit.isSpeedUnit
    }

    public var displayValue: String {
        if isPacingUnit {
            let totalSeconds = Int((value * 60).rounded())
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"

            return "\(minutes):\(secondsString)"
        }

        return "\(value.rounded(toPlaces: 1))"
    }

    public var displayUnit: String {
        return unit.description
    }

    public init(value: Double, unit: PaceUnit) {
        self.value = value
        self.unit = unit
    }

    public init(stringValue: String, unit: PaceUnit) {
        self.value = 0
        self.unit = unit
        self.updateValue(stringValue)
    }

    public static func minPerKm(seconds: Int) -> Pace {
        return Pace(value: Double(seconds) / 60.0, unit: .minPerKm)
    }

    public static func minPerMile(seconds: Int) -> Pace {
        return Pace(value: Double(seconds) / 60.0, unit: .minPerMile)
    }

    // convenience method to update the value from a String representation
    // `xx:yy` for isPacingUnit
    // `x` for mph, kmph
    mutating public func updateValue(_ stringValue: String) {
        guard !stringValue.isEmpty else { return }
        if isPacingUnit {
            let components = stringValue.components(separatedBy: ":")
            guard components.count >= 2 else { return }

            let minString = components[0]
            let secString = components[1]

            guard let min = Int(minString), let sec = Int(secString) else { return }

            let totalSeconds = Double(min) * 60.0 + Double(sec)
            self.value = totalSeconds / 60.0
        }
        else {
            guard let doubleValue = Double(stringValue) else { return }
            self.value = doubleValue
        }
    }

    public func converted(to targetUnit: PaceUnit) -> Pace {
        if self.unit == targetUnit { return self }

        let currentSpeed = Measurement(value: value, unit: self.unit.toUnitSpeed())
        let targetSpeed = currentSpeed.converted(to: targetUnit.toUnitSpeed())

        return Pace(value: targetSpeed.value, unit: targetUnit)
    }

}

extension Pace: Equatable {
    public static func == (lhs: Pace, rhs: Pace) -> Bool {
        return lhs.unit == rhs.unit && lhs.value == rhs.value
    }
}

public enum PaceUnit: String, Codable {
    case minPerKm
    case minPerMile
    case kmPerHour
    case milePerHour

    public var isPacingUnit: Bool {
        return self == .minPerKm || self == .minPerMile
    }

    public var isSpeedUnit: Bool {
        return self == .kmPerHour || self == .milePerHour
    }

    public var description: String {
        switch self {
        case .minPerKm:    return "min/km"
        case .minPerMile:  return "min/mile"
        case .kmPerHour:   return "km/h"
        case .milePerHour: return "mile/h"
        }
    }

    public var inputSource: [[CustomStringConvertible]] {
        switch self {
        case .minPerKm:    return PaceUnit.paceInputs
        case .minPerMile:  return PaceUnit.paceInputs
        case .kmPerHour:   return PaceUnit.speedInputs
        case .milePerHour: return PaceUnit.speedInputs
        }
    }

    public static let paceInputs: [[CustomStringConvertible]] = [Array(0...59), [":"], Array(0...59).map { String(format: "%02d", arguments:[$0]) }]
    public static let speedInputs: [[CustomStringConvertible]] = [Array(0...100), ["."],  Array(0...9)]
//    public static let speedInputs: [[CustomStringConvertible]] = [Array(0...100), Array(0...9).map { ".\($0)" } ]

    public static func fromDescription(_ description: String) -> PaceUnit? {
        switch description {
        case PaceUnit.minPerKm.description:    return .minPerKm
        case PaceUnit.minPerMile.description:  return .minPerMile
        case PaceUnit.kmPerHour.description:   return .kmPerHour
        case PaceUnit.milePerHour.description: return .milePerHour
        default:
            return nil
        }
    }

    public func toUnitSpeed() -> UnitSpeed {
        switch self {
        case .minPerKm:    return UnitSpeed.minutesPerKilometer
        case .minPerMile:  return UnitSpeed.minutesPerMile
        case .kmPerHour:   return UnitSpeed.kilometersPerHour
        case .milePerHour: return UnitSpeed.milesPerHour
        }
    }
}

public extension UnitSpeed {
    class var secondsPerMeter: UnitSpeed {
        return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
    }

    class var minutesPerKilometer: UnitSpeed {
        return UnitSpeed(symbol: "min/km", converter: UnitConverterPace(coefficient: 60.0 / 1000.0))
    }

    class var minutesPerMile: UnitSpeed {
        return UnitSpeed(symbol: "min/mi", converter: UnitConverterPace(coefficient: 60.0 / 1609.34))
    }
}

public class UnitConverterPace: UnitConverter {
    private let coefficient: Double

    init(coefficient: Double) {
        self.coefficient = coefficient
    }

    override public func baseUnitValue(fromValue value: Double) -> Double {
        return reciprocal(value * coefficient)
    }

    override public func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return reciprocal(baseUnitValue * coefficient)
    }

    private func reciprocal(_ value: Double) -> Double {
        guard value != 0 else { return 0 }
        return 1.0 / value
    }
}


