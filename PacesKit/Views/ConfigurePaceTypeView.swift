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

    @IBOutlet weak var dimView: DimView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var ibConstraint: NSLayoutConstraint!
    var contentShowConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var contentHideConstraint: NSLayoutConstraint = NSLayoutConstraint()

    @IBOutlet weak var paceMinKm: PaceTypeButton!
    @IBOutlet weak var paceMinMi: PaceTypeButton!
    @IBOutlet weak var paceKph: PaceTypeButton!
    @IBOutlet weak var paceMph: PaceTypeButton!
    @IBOutlet weak var raceMarathon: PaceTypeButton!
    @IBOutlet weak var raceHalfMarathon: PaceTypeButton!
    @IBOutlet weak var race10K: PaceTypeButton!
    @IBOutlet weak var race5K: PaceTypeButton!
    @IBOutlet weak var raceCustomDistance: CustomDistanceInput!
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
        super.awakeFromNib()
        setup()
        bindViewModel()
    }

    // animate the configuration screen in place
    public func show() {
        dimView.show()

        layoutIfNeeded()
        let timingParams = UISpringTimingParameters(dampingRatio: 0.7, initialVelocity: CGVector(dx: 0, dy: 0.7))
        let animator = UIViewPropertyAnimator(duration: 0.3, timingParameters: timingParams)
        animator.addAnimations {
            self.contentHideConstraint.isActive = false
            self.contentShowConstraint.isActive = true

            self.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func bindViewModel() {
        guard viewModel != nil else { return }

        selectInitalType()

        viewModel.outputs.paceTypeUpdated
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss()
            })
            .disposed(by: bag)

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

        raceCustomDistance.selectedDistance
            .map { distance in RaceType.custom(distance) }
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

    func selectInitalType() {
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
            case .custom(let distance): raceCustomDistance.updateDistance(distance)
            }
            switch race.raceDistance.distanceUnit {
            case .km: raceDistanceKm.isSelected = true
            case .mile: raceDistanceMile.isSelected = true
            }
        }
    }

    func setup() {
        setupUI()
        setupGestures()
        observeKeyboard()
    }

    func setupUI() {
        //disable Interface Builder constraint, and use these show/hide cosntraints.
        ibConstraint.isActive = false
        contentShowConstraint = self.scrollView.centerYAnchor.constraint(equalTo: centerYAnchor)
        contentHideConstraint = self.scrollView.topAnchor.constraint(equalTo: bottomAnchor)
        contentShowConstraint.isActive = false
        contentHideConstraint.isActive = true

        let theme = AppEnvironment.current.theme

        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = shadowOpacity
        contentView.layer.shadowOffset = CGSize.zero
        contentView.layer.shadowRadius = shadowRadius
        contentView.layer.borderColor = borderColor.cgColor
        contentView.layer.borderWidth = borderWidth
        contentView.layoutMargins = UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
        contentView.backgroundColor = theme.backgroundColor

        paceMinKm.setTitle(PaceUnit.minPerKm.description, for: .normal)
        paceMinMi.setTitle(PaceUnit.minPerMile.description, for: .normal)
        paceKph.setTitle(PaceUnit.kmPerHour.description, for: .normal)
        paceMph.setTitle(PaceUnit.milePerHour.description, for: .normal)

        raceMarathon.setTitle(RaceType.marathon.name, for: .normal)
        raceHalfMarathon.setTitle(RaceType.halfMarathon.name, for: .normal)
        race10K.setTitle(RaceType.km10.name, for: .normal)
        race5K.setTitle(RaceType.km5.name, for: .normal)

        raceDistanceKm.setTitle(DistanceUnit.km.description, for: .normal)
        raceDistanceMile.setTitle(DistanceUnit.mile.description, for: .normal)
    }

    func setupGestures() {
        let dismissGesture = UITapGestureRecognizer()
        scrollViewContentView.addGestureRecognizer(dismissGesture)
        dismissGesture.rx.event
            .map { _ in }
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss()
            })
            .disposed(by: bag)

        //easiest way to stop propagating taps from the contentView to the scrollContentView
        let ignore = UITapGestureRecognizer()
        contentView.addGestureRecognizer(ignore)
    }

    func observeKeyboard() {
        NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillChangeFrame)
            .subscribe(onNext: { [weak self] notification in
                guard let _self = self,
                    let userInfo = notification.userInfo,
                    let frameEndValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }

                let keyboardScreenEndFrame = frameEndValue.cgRectValue
                let keyboardViewEndFrame = _self.convert(keyboardScreenEndFrame, from: _self.window)

                let actualHeight = keyboardViewEndFrame.height - _self.safeAreaInsets.bottom
                _self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: actualHeight, right: 0)

                _self.scrollView.scrollIndicatorInsets = _self.scrollView.contentInset

//                let selectedRange = contentView.selectedRange
//                contentView.scrollRangeToVisible(selectedRange)
            })
            .disposed(by: bag)

        Observable.merge(
            NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide),
            NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardDidHide)
            )
            .subscribe(onNext: { [weak self] notification in
                self?.scrollView.contentInset = UIEdgeInsets.zero
            })
            .disposed(by: bag)
    }

    func dismiss() {
        dimView.hide()

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.contentShowConstraint.isActive = false
            self.contentHideConstraint.isActive = true

            self.layoutIfNeeded()
        }, completion: { _ in
            self.viewModel.outputs.configureFinished.accept(())
        })
    }


}

