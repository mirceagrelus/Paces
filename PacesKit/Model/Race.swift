//
//  RaceDistance.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-23.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public struct Race: Codable {
    // time in seconds
    public var time: Double
    public var raceDistance: RaceDistance

    public var inputSource: [[CustomStringConvertible]] {
        return [Array(0...99),
                [":"],
                Array(0...59).map { String(format: "%02d", arguments:[$0]) },
                [":"],
                Array(0...59).map { String(format: "%02d", arguments:[$0]) }]
    }

    public var displayValue: String {
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(seconds: Int(round(time)))
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"

        return "\(hours):\(minutesString):\(secondsString)"
    }

    public init(time: Double, raceDistance: RaceDistance) {
        self.time = time
        self.raceDistance = raceDistance
    }

    public init(stringValue: String, raceDistance: RaceDistance) {
        self.time = 0
        self.raceDistance = raceDistance
        self.updateValue(stringValue)
    }

    // convenience method to update the value from a String representation
    // `hh:mm:ss`
    mutating public func updateValue(_ stringValue: String) {
        guard !stringValue.isEmpty else { return }

        let components = stringValue.components(separatedBy: ":")
        guard components.count >= 3 else { return }

        let hourString = components[0]
        let minString = components[1]
        let secString = components[2]

        guard let hour = Int(hourString), let min = Int(minString), let sec = Int(secString) else { return }

        let totalSeconds = Double(hour) * 3600 + Double(min) * 60.0 + Double(sec)
        self.time = totalSeconds
    }

    // TODO: take out of here
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    public func converted(to paceUnit: PaceUnit) -> Pace {
        let currenSeconds = self.time
        let currentMeters = self.raceDistance.coefficient

        var speedValue = currentMeters / currenSeconds
        if !speedValue.isFinite { speedValue = 0 }

        let currentSpeed = Measurement(value: speedValue, unit: UnitSpeed.metersPerSecond)
        let targetSpeed = currentSpeed.converted(to: paceUnit.toUnitSpeed())

        return Pace(value: targetSpeed.value, unit: paceUnit)
    }

    public func converted(to newRaceDistance: RaceDistance) -> Race {
        if self.raceDistance.coefficient == newRaceDistance.coefficient &&
            self.raceDistance.distanceUnit == newRaceDistance.distanceUnit { return self }

        var currentMetersPerSecond = self.raceDistance.coefficient / self.time
        if !currentMetersPerSecond.isFinite { currentMetersPerSecond = 0 }

        var newRaceSeconds = newRaceDistance.coefficient / currentMetersPerSecond
        if !newRaceSeconds.isFinite { newRaceSeconds = 0 }

        return Race(time: newRaceSeconds, raceDistance: newRaceDistance)
    }
}

extension Race: Equatable {
    // technically races configured with different distance units could be considered equal,
    // but we consider equality as in a user's configuration of the race
    public static func == (lhs: Race, rhs: Race) -> Bool {
        return lhs.raceDistance == rhs.raceDistance && lhs.time == rhs.time
    }
}

public struct RaceDistance: Codable {
    public var raceType: RaceType
    public var distanceUnit: DistanceUnit

    public init(raceType: RaceType, distanceUnit: DistanceUnit) {
        self.raceType = raceType
        self.distanceUnit = distanceUnit
    }

    // coefficient for the SI unit of length - (m)
    public var coefficient: Double {
        switch raceType {
        case .km5: return 5_000
        case .km10: return 10_000
        case .halfMarathon: return 21_097.5
        case .marathon: return 42_195
        case .custom(let val): return val * distanceUnit.coefficient
        }
    }

    public var distanceDescription: String {
        let val = String(format: "%.1f", (self.coefficient / self.distanceUnit.coefficient))
        return "\(val) \(self.distanceUnit.description)"
    }

    public var nameDescription: String {
        return self.raceType.name
    }

    public var accessibilityLabel: String {
        switch raceType {
        case .km5: return "5k"
        case .km10: return "10k"
        case .halfMarathon: return "Half Marathon"
        case .marathon: return "Marathon"
        case .custom(let val): return "Custom, \(val) \(distanceUnit.accessibilityLabel)"
        }
    }

}

extension RaceDistance: Equatable {
    public static func == (lhs: RaceDistance, rhs: RaceDistance) -> Bool {
        return lhs.raceType == rhs.raceType && lhs.distanceUnit == rhs.distanceUnit
    }
}

public enum RaceType: Codable {
    case km5
    case km10
    case halfMarathon
    case marathon
    case custom(Double)

    public var name: String {
        switch self {
        case .km5: return "5k"
        case .km10: return "10k"
        case .halfMarathon: return "Half Marathon"
        case .marathon: return "Marathon"
        case .custom: return "Custom"
        }
    }

    // for Codable conformance
    private enum CodingKeys: CodingKey {
        case km5
        case km10
        case halfMarathon
        case marathon
        case custom
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .km5: try container.encode("", forKey: .km5)
        case .km10: try container.encode("", forKey: .km10)
        case .halfMarathon: try container.encode("", forKey: .halfMarathon)
        case .marathon: try container.encode("", forKey: .marathon)
        case .custom(let distance): try container.encode(distance, forKey: .custom)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try container.decodeIfPresent(String.self, forKey: .km5) {
            self = .km5
        } else if let _ = try container.decodeIfPresent(String.self, forKey: .km10) {
            self = .km10
        } else if let _ = try container.decodeIfPresent(String.self, forKey: .halfMarathon) {
            self = .halfMarathon
        } else if let _ = try container.decodeIfPresent(String.self, forKey: .marathon) {
            self = .marathon
        } else if let distance = try container.decodeIfPresent(Double.self, forKey: .custom) {
            self = .custom(distance)
        } else {
            // something went wrong. Just default to a value instead of throwing
            self = .halfMarathon
        }
    }

}

extension RaceType: Equatable {
    public static func == (lhs: RaceType, rhs: RaceType) -> Bool {
        switch (lhs, rhs) {
        case let (.custom(l), .custom(r)): return l == r
        default: return lhs.name == rhs.name
        }
    }
}

public enum DistanceUnit: String, Codable {
    case km
    case mile

    public var description: String {
        switch self {
        case .km: return "km"
        case .mile: return "mi"
        }
    }

    // coefficient for the SI unit of length - the meter (m)
    public var coefficient: Double {
        switch self {
        case .km: return 1000.0
        case .mile: return 1609.34
        }
    }

    public var accessibilityLabel: String {
        switch self {
        case .km: return "kilometers"
        case .mile: return "miles"
        }
    }
}

