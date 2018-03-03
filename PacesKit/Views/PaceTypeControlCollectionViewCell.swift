//
//  PaceTypeControlCollectionViewCell.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceTypeControlCollectionViewCell: ConversionControlCollectionViewCell {

    public static let identifier = "PaceTypeControlCell"
    public var paceTypeControlView: PaceTypeControlView = PaceTypeControlView()

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
        paceTypeControlView.removeFromSuperview()
        paceTypeControlView = PaceTypeControlView()
        setupControl()
    }

    public func configureFor(control: ConversionControl) {
        paceTypeControlView.configureFor(control)
    }

    func setupControl() {
        paceTypeControlView.translatesAutoresizingMaskIntoConstraints = false
        controlContentView.addSubview(paceTypeControlView)

        AutoLayoutUtils.constrainView(paceTypeControlView, equalToView: controlContentView)

    }
    
}

