//
//  AddControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-22.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit

public class AddControlView: UICollectionReusableView {

    public static let identifier = "AddControlView"
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var addLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        let theme = AppEnvironment.current.theme

        addImageView.tintColor = theme.controlCellBackgroundColorSelected
        addLabel.textColor = theme.controlCellTextColor
    }
    
}
