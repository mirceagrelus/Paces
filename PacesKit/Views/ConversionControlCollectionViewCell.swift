//
//  ConversionControlCollectionViewCell.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-20.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class ConversionControlCollectionViewCell: UICollectionViewCell {

    var controlContentView: UIView = UIView()
    public var controlContentTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    public var maxDragDistance: CGFloat = 80

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
    }

    func setup() {
        controlContentView.translatesAutoresizingMaskIntoConstraints = false
        //controlContentView.backgroundColor = .yellow
        contentView.addSubview(controlContentView)

        NSLayoutConstraint.activate([
            controlContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            controlContentView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            controlContentView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
            ])
        controlContentTrailingConstraint = controlContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        controlContentTrailingConstraint.isActive = true

    }
}
