//
//  ConfiguredPace.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation

public struct ConversionControl: Codable {
    public var id: Int
    public var paceType: PaceType

    public init(id: Int, paceType: PaceType) {
        self.id = id
        self.paceType = paceType
    }
}

extension ConversionControl: Equatable {
    public static func == (lhs: ConversionControl, rhs: ConversionControl) -> Bool {
        return lhs.id == rhs.id && lhs.paceType == rhs.paceType
    }
}


