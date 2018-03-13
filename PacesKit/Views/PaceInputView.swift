//
//  PaceInputView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-22.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class PaceInputView: ThemeView {

    let shadowOpacity: Float = 0.2
    let shadowRadius: CGFloat = 5
    let borderWidth: CGFloat = 1.0
    let borderColor: UIColor = UIColor.black.withAlphaComponent(0.5)

    public override init(color: @autoclosure @escaping () -> UIColor?) {
        super.init(color: color)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius

        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = borderColor
        addSubview(border)
        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: topAnchor, constant: -borderWidth),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: borderWidth) ])
    }

}
