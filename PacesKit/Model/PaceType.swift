//
//  PaceType.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-16.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public enum PaceType {
    case pace(Pace)
    case race(Race)

    public var displayValue: String {
        switch self {
        case .pace(let pace): return pace.displayValue
        case .race(let race): return race.displayValue
        }
    }

    public var distanceUnit: DistanceUnit {
        switch self {
        case .pace(let pace): return pace.unit.distanceUnit
        case .race(let race): return race.raceDistance.distanceUnit
        }
    }

    // for Codable conformance
    private enum CodingKeys: CodingKey {
        case pace
        case race
    }

    public func converted(to paceType: PaceType) -> PaceType {
        switch paceType {
        case .pace(let pace): return .pace(self.converted(to: pace.unit))
        case .race(let race): return .race(self.converted(to: race.raceDistance))

        }
    }

    public func converted(to paceUnit: PaceUnit) -> Pace {
        switch self {
        case .pace(let pace): return pace.converted(to: paceUnit)
        case .race(let race): return race.converted(to: paceUnit)
        }
    }

    public func converted(to raceDistance: RaceDistance) -> Race {
        switch self {
        case .pace(let pace): return pace.converted(to: raceDistance)
        case .race(let race): return race.converted(to: raceDistance)
        }
    }

    public func withUpdatedValue(_ stringValue: String) -> PaceType {
        switch self {
        case .pace(let pace): return .pace(Pace(stringValue: stringValue, unit: pace.unit))
        case .race(let race): return .race(Race(stringValue: stringValue, raceDistance: race.raceDistance) )
        }
    }

    public static func equalUnits(lhs: PaceType, rhs: PaceType) -> Bool {
        switch (lhs, rhs) {
        case let (.pace(l), .pace(r)): return l.unit == r.unit
        case let (.race(l), .race(r)): return l.raceDistance == r.raceDistance
        case (.pace, _),
             (.race, _): return false
        }
    }

    public static var defaultValue: PaceType {
        return PaceType.pace(Pace.minPerMile(seconds: 0))
    }
}

extension PaceType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .pace(let pace): try container.encode(pace, forKey: .pace)
        case .race(let race): try container.encode(race, forKey: .race)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let pace = try container.decodeIfPresent(Pace.self, forKey: .pace) {
            self = .pace(pace)
        } else if let race = try container.decodeIfPresent(Race.self, forKey: .race) {
            self = .race(race)
        } else {
            // something went wrong. Just default to a value instead of throwing
            self = PaceType.defaultValue
        }
    }
}

extension PaceType: Equatable {
    public static func == (lhs: PaceType, rhs: PaceType) -> Bool {
        switch (lhs, rhs) {
        case let (.pace(l), .pace(r)): return l == r
        case let (.race(l), .race(r)): return l == r
        case (.pace, _),
             (.race, _): return false
        }
    }
}
