//
//  DistanceControlCollectionViewCell.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-20.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class DistanceControlCollectionViewCell: ConversionControlCollectionViewCell {

    public static let identifier = "DistanceControlCell"
    public var distanceControl: DistanceControlView = DistanceControlView.fromNib()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupControl()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupControl()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        // just replace with a new distance control
        distanceControl.removeFromSuperview()
        distanceControl = DistanceControlView.fromNib()
        setupControl()
    }

    func setupControl() {
        distanceControl.translatesAutoresizingMaskIntoConstraints = false
        controlContentView.addSubview(distanceControl)

        AutoLayoutUtils.constrainView(distanceControl, equalToView: controlContentView)
    }

}
