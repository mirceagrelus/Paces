//
//  PaceControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class PaceControlView: ThemeView {

    @IBOutlet weak var valueLabel: ConversionControlLabel!
    @IBOutlet weak var unitLabel: ConversionControlLabel!
    @IBOutlet weak var sourceLabel: ConversionControlLabel!
    @IBOutlet weak var pickUnitImageView: UIImageView!

    public static let sourceFromString = "From"
    public static let sourceToString = "To"
    
    public var viewModel: PaceControlViewModelType = PaceControlViewModel() { didSet { self.bindViewModel() }}
    public let bag = DisposeBag()

    public override func awakeFromNib() {
        self.bindViewModel()
    }

    func bindViewModel() {
        viewModel.inputs.pace
            .map { $0.unit.description }
            .bind(to: unitLabel.rx.text)
            .disposed(by: bag)

        viewModel.inputs.pace
            .map { $0.displayValue }
            .bind(to: valueLabel.rx.text)
            .disposed(by: bag)

        //viewModel.outputs.isSelected
        viewModel.inputs.isSelected
            .debug("isSelected")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                let theme = AppEnvironment.current.theme
                //self?.sourceLabel.text = isSelected ? PaceControlView.sourceFromString : PaceControlView.sourceToString
                self?.applyBackgroundColor = isSelected ? { theme.controlCellBackgroundColorSelected } : { theme.controlCellBackgroundColor }
                self?.pickUnitImageView.tintColor = isSelected ?  theme.controlCellTextColorSelected : theme.controlCellTextColor
                //self?.sourceLabel.isSelected = isSelected
                self?.valueLabel.isSelected = isSelected
                self?.unitLabel.isSelected = isSelected

                //self?.sourceLabel.alpha = isSelected ? 1.0 : 0.0
            })
            .disposed(by: bag)

        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: viewModel.inputs.tapped)
            .disposed(by: bag)

        let configureTap = UITapGestureRecognizer()
        unitLabel.addGestureRecognizer(configureTap)
        unitLabel.isUserInteractionEnabled = true
        configureTap.rx.event
            .map { _ in }
            .bind(to: viewModel.inputs.configureTapped)
            .disposed(by: bag)

    }

}




