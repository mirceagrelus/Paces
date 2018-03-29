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
    @IBOutlet weak var editButton: ThemeButton!
    @IBOutlet weak var paceAccessibilityView: UIView!

    public var viewModel: PaceControlViewModelType = PaceControlViewModel() { didSet { bindViewModel() }}
    public let bag = DisposeBag()

    public override func awakeFromNib() {
        bindViewModel()
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

        viewModel.inputs.isSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                self?.applyBackgroundColor = isSelected ?
                    { AppEnvironment.current.theme.controlCellBackgroundColorSelected } :
                    { AppEnvironment.current.theme.controlCellBackgroundColor }
                self?.editButton.applyTintColor = isSelected ?
                    { AppEnvironment.current.theme.controlCellTextColorSelected } :
                    { AppEnvironment.current.theme.controlCellTextColor }
                self?.valueLabel.isSelected = isSelected
                self?.unitLabel.isSelected = isSelected
            })
            .disposed(by: bag)

        Observable
            .combineLatest(viewModel.inputs.pace,
                           viewModel.inputs.isSelected)
            .subscribe(onNext: { [weak self] (pace, isSelected) in
                guard let _self = self else { return }
                let selected = isSelected ? "selected, " : ""
                _self.paceAccessibilityView.accessibilityLabel = "\(selected)\(pace.displayValue), \(pace.unit.accessibilityLabel)"
                _self.editButton.accessibilityLabel = "Edit pace \(pace.unit.accessibilityLabel)"
            })
            .disposed(by: bag)

        let tapGesture = UITapGestureRecognizer()
        addGestureRecognizer(tapGesture)
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: viewModel.inputs.tapped)
            .disposed(by: bag)

        editButton.rx.tap
            .map { _ in }
            .bind(to: viewModel.inputs.configureTapped)
            .disposed(by: bag)

    }

}




