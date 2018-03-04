//
//  PaceInputView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-22.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceInputView: UIView {

    let shadowOpacity: Float = 0.5
    let shadowRadius: CGFloat = 10
    let borderWidth: CGFloat = 1.0
    let borderColor: UIColor = UIColor.black.withAlphaComponent(0.5)

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        let theme = AppEnvironment.current.theme
        self.backgroundColor = theme.inputViewBackgroundColor

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius

        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = borderColor
        self.addSubview(border)
        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: self.topAnchor, constant: -borderWidth),
            border.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: borderWidth) ])
    }

}
