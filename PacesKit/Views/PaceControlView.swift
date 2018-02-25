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

    public static let sourceFromString = "From"
    public static let sourceToString = "To"
    
    public let viewModel: PaceControlViewModelType = PaceControlViewModel()
    public let bag = DisposeBag()

    public override func awakeFromNib() {
        self.bindViewModel()

        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .map { _ in () }
            .bind(to: viewModel.inputs.tapped)
            .disposed(by: bag)
    }

    public func configureUnit(_ unit: PaceUnit) {
        viewModel.inputs.toUnit.accept(unit)
    }

    func bindViewModel() {
        viewModel.outputs.pace
            .map { $0.unit.description }
            .bind(to: unitLabel.rx.text)
            .disposed(by: bag)

        viewModel.outputs.pace
            .map { $0.displayValue }
            .bind(to: valueLabel.rx.text)
            .disposed(by: bag)

        viewModel.outputs.isSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                let theme = AppEnvironment.current.theme
                self?.sourceLabel.text = isSelected ? PaceControlView.sourceFromString : PaceControlView.sourceToString
                self?.applyBackgroundColor = isSelected ? { theme.controlCellBackgroundColorSelected } : { theme.controlCellBackgroundColor }
                self?.sourceLabel.isSelected = isSelected
                self?.valueLabel.isSelected = isSelected
                self?.unitLabel.isSelected = isSelected
            })
            .disposed(by: bag)

    }

}

extension PaceControlView {
    public class func createWithPaceUnit(_ unit: PaceUnit) -> PaceControlView {
        let paceControl: PaceControlView = PaceControlView.fromNib()
        paceControl.configureUnit(unit)
        return paceControl
    }
}


