//
//  DistanceControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-20.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class DistanceControlView: ThemeView {

    @IBOutlet weak var valueLabel: ConversionControlLabel!
    @IBOutlet weak var raceTypeLabel: ConversionControlLabel!
    @IBOutlet weak var raceDistanceLabel: ConversionControlLabel!
    @IBOutlet weak var separatorLabel: ConversionControlLabel!
    @IBOutlet weak var pickUnitImageView: UIImageView!
    
    public var viewModel: DistanceControlViewModelType = DistanceControlViewModel() { didSet { self.bindViewModel() }}
    public let bag = DisposeBag()

    public override func awakeFromNib() {
        self.bindViewModel()
    }

    func bindViewModel() {
        viewModel.inputs.race
            .map { $0.raceDistance.nameDescription }
            .bind(to: raceTypeLabel.rx.text)
            .disposed(by: bag)

        viewModel.inputs.race
            .map { $0.raceDistance.distanceDescription }
            .bind(to: raceDistanceLabel.rx.text)
            .disposed(by: bag)

        viewModel.inputs.race
            .map { $0.displayValue }
            .bind(to: valueLabel.rx.text)
            .disposed(by: bag)

        viewModel.inputs.isSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSelected in
                let theme = AppEnvironment.current.theme
                self?.applyBackgroundColor = isSelected ? { theme.controlCellBackgroundColorSelected } : { theme.controlCellBackgroundColor }
                self?.pickUnitImageView.tintColor = isSelected ?  theme.controlCellTextColorSelected : theme.controlCellTextColor
                self?.valueLabel.isSelected = isSelected
                self?.raceTypeLabel.isSelected = isSelected
                self?.raceDistanceLabel.isSelected = isSelected
                self?.separatorLabel.isSelected = isSelected
            })
            .disposed(by: bag)

        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .map { _ in () }
            .bind(to: viewModel.inputs.tapped)
            .disposed(by: bag)
    }

}


