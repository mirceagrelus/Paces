//
//  ConfigurePaceTypeView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-26.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class ConfigurePaceTypeView: UIView {
    public static func configuredWith(_ model: ConfigurePaceTypeViewModelType) -> ConfigurePaceTypeView {
        let configurePaceTypeView: ConfigurePaceTypeView = ConfigurePaceTypeView.fromNib()
        configurePaceTypeView.viewModel = model

        return configurePaceTypeView
    }

    public var viewModel: ConfigurePaceTypeViewModelType! { didSet { self.bindViewModel() }}
    public let bag = DisposeBag()

    @IBOutlet weak var paceMinKm: PaceTypeButton!
    @IBOutlet weak var paceMinMi: PaceTypeButton!
    @IBOutlet weak var paceKph: PaceTypeButton!
    @IBOutlet weak var paceMph: PaceTypeButton!
    @IBOutlet weak var raceMarathon: PaceTypeButton!
    @IBOutlet weak var raceHalfMarathon: PaceTypeButton!
    @IBOutlet weak var race10K: PaceTypeButton!
    @IBOutlet weak var race5K: PaceTypeButton!
    @IBOutlet weak var raceCustom: PaceTypeButton!
    @IBOutlet weak var raceDistanceKm: PaceTypeButton!
    @IBOutlet weak var raceDistanceMile: PaceTypeButton!

    let edgeInset: CGFloat = 20
    let shadowOpacity: Float = 0.5
    let shadowRadius: CGFloat = 5
    let borderWidth: CGFloat = 1.0
    let borderColor: UIColor = UIColor.black.withAlphaComponent(0.5)


    deinit {
        print("ConfigurePaceTypeView - deinit")
    }

    public override func awakeFromNib() {
        setup()
        bindViewModel()

    }

    func setup() {
        let theme = AppEnvironment.current.theme
        backgroundColor = theme.backgroundColor
        layoutMargins = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth

    }

    func bindViewModel() {
        guard viewModel != nil else { return }

        selectInital()

        paceMinKm.rx.tap
            .map { _ in .minPerKm }
            .bind(to: viewModel.inputs.selectedPaceUnit)
            .disposed(by: bag)

        paceMinMi.rx.tap
            .map { _ in .minPerMile }
            .bind(to: viewModel.inputs.selectedPaceUnit)
            .disposed(by: bag)

        paceKph.rx.tap
            .map { _ in .kmPerHour }
            .bind(to: viewModel.inputs.selectedPaceUnit)
            .disposed(by: bag)

        paceMph.rx.tap
            .map { _ in .milePerHour }
            .bind(to: viewModel.inputs.selectedPaceUnit)
            .disposed(by: bag)

        raceMarathon.rx.tap
            .map { _ in RaceType.marathon }
            .bind(to: viewModel.inputs.selectedRaceType)
            .disposed(by: bag)

        raceHalfMarathon.rx.tap
            .map { _ in RaceType.halfMarathon }
            .bind(to: viewModel.inputs.selectedRaceType)
            .disposed(by: bag)

        race10K.rx.tap
            .map { _ in RaceType.km10 }
            .bind(to: viewModel.inputs.selectedRaceType)
            .disposed(by: bag)

        race5K.rx.tap
            .map { _ in RaceType.km5 }
            .bind(to: viewModel.inputs.selectedRaceType)
            .disposed(by: bag)

        raceCustom.rx.tap
            .map { _ in RaceType.custom(0) }
            .bind(to: viewModel.inputs.selectedRaceType)
            .disposed(by: bag)

        raceDistanceKm.rx.tap
            .map { _ in DistanceUnit.km }
            .do(onNext: { [weak self] _ in
                self?.raceDistanceMile.isSelected = false
                self?.raceDistanceKm.isSelected = true
            })
            .bind(to: viewModel.inputs.selectedRaceDistanceUnit)
            .disposed(by: bag)

        raceDistanceMile.rx.tap
            .map { _ in DistanceUnit.mile }
            .do(onNext: { [weak self] _ in
                self?.raceDistanceMile.isSelected = true
                self?.raceDistanceKm.isSelected = false
            })
            .bind(to: viewModel.inputs.selectedRaceDistanceUnit)
            .disposed(by: bag)
    }

    func selectInital() {
        switch viewModel.inputs.paceType {
        case .pace(let pace):
            switch pace.unit {
            case .minPerKm: paceMinKm.isSelected = true
            case .minPerMile: paceMinMi.isSelected = true
            case .kmPerHour: paceKph.isSelected = true
            case .milePerHour: paceMph.isSelected = true
            }
        case .race(let race):
            switch race.raceDistance.raceType {
            case .marathon: raceMarathon.isSelected = true
            case .halfMarathon: raceHalfMarathon.isSelected = true
            case .km10: race10K.isSelected = true
            case .km5: race5K.isSelected = true
            case .custom(_): raceCustom.isSelected = true
            }
            switch race.raceDistance.distanceUnit {
            case .km: raceDistanceKm.isSelected = true
            case .mile: raceDistanceMile.isSelected = true
            }
        }
    }


}
