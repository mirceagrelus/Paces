//
//  PaceControlCollectionViewCell.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceControlCollectionViewCell: ConversionControlCollectionViewCell {

    public static let identifier = "PaceControlCell"
    public var paceControl: PaceControlView = PaceControlView.fromNib()

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

        // just replace with a new PaceControl.
        paceControl.removeFromSuperview()
        paceControl = PaceControlView.fromNib()
        setupControl()
    }

    public func configureFor(unit: PaceUnit) {
        paceControl.configureUnit(unit)
    }

    func setupControl() {
        paceControl.translatesAutoresizingMaskIntoConstraints = false
        controlContentView.addSubview(paceControl)

        AutoLayoutUtils.constrainView(paceControl, equalToView: controlContentView)

    }
    
}

