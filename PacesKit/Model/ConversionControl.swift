//
//  ConfiguredPace.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public struct ConversionControl: Codable {
    public var sortOrder: Int
    public var paceType: PaceType

    public init(sortOrder: Int, paceType: PaceType) {
        self.sortOrder = sortOrder
        self.paceType = paceType

    }

    public static func orderSort(_ lhs: ConversionControl, _ rhs: ConversionControl) -> Bool {
        return (lhs.sortOrder) < (rhs.sortOrder)
    }
}

public enum PaceType: Codable {
    case pace(Pace)
    case race(Race)

    public var displayValue: String {
        switch self {
        case .pace(let pace): return pace.displayValue
        case .race(let race): return race.displayValue
        }
    }

    // for Codable conformance
    private enum CodingKeys: CodingKey {
        case pace
        case race
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
            self = .pace(Pace.minPerMile(seconds: 0))
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

