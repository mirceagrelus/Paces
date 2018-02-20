//
//  PaceControlCollectionViewCell.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-18.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceControlCollectionViewCell: UICollectionViewCell {

    public static let PaceCellIdentifier = "PaceControlCell"
    public var paceControl: PaceControlView = PaceControlView.fromNib()
    public var controlContentTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()

    let backgroundContentView: UIView = UIView()
    let actionsContentView: UIView = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        // just replace with a new PaceControl.
        paceControl.removeFromSuperview()
        paceControl = PaceControlView.fromNib()
        setupPaceControl()
    }

    public func configureFor(unit: PaceUnit) {
        paceControl.configureUnit(unit)
    }


    func setup() {
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        //contentView.backgroundColor = UIColor.blue

        backgroundContentView.translatesAutoresizingMaskIntoConstraints = false
        //backgroundContentView.backgroundColor = .yellow
        contentView.addSubview(backgroundContentView)

        AutoLayoutUtils.constrainView(backgroundContentView, equalToView: contentView)

        //now setup the pace control
        setupPaceControl()
    }

    func setupPaceControl() {
        paceControl.translatesAutoresizingMaskIntoConstraints = false
        backgroundContentView.addSubview(paceControl)

        NSLayoutConstraint.activate([
            paceControl.topAnchor.constraint(equalTo: backgroundContentView.topAnchor),
            paceControl.widthAnchor.constraint(equalTo: backgroundContentView.widthAnchor),
            paceControl.heightAnchor.constraint(equalTo: backgroundContentView.heightAnchor)
            ])
        controlContentTrailingConstraint = paceControl.trailingAnchor.constraint(equalTo: backgroundContentView.trailingAnchor)
        controlContentTrailingConstraint.isActive = true

    }
    
}

