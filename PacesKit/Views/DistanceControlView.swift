//
//  DistanceControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-20.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class DistanceControlView: UIView {



}

extension DistanceControlView {
    public static func createWithDistanceUnit() -> DistanceControlView {
        let distanceControl: DistanceControlView = DistanceControlView.fromNib()
        return distanceControl
    }
}
