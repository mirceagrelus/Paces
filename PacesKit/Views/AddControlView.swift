//
//  AddControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-22.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

public class AddControlView: UICollectionReusableView {

    public static let identifier = "AddControlView"
    @IBOutlet weak var addButton: PaceTypeButton!

    public var addAction: CocoaAction? { didSet { addButton.rx.action = addAction }}

    public override func awakeFromNib() {
        super.awakeFromNib()

        addButton.applyBackgroundColor = { UIColor.clear }
        addButton.applySelectedBackgroundColor = { UIColor.clear }
        addButton.applyStyle()
    }

}
