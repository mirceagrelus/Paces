//
//  PickUnitView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-25.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PickUnitView: UIView {

    let iconImageView: UIImageView = UIImageView(image: UIImage.init(named: "arrow-down-large"))

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        iconImageView.isHidden = true
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }

}
