//
//  CustomDistanceTextField.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-03-05.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class CustomDistanceInput: UIView {

    var applyTextColor: () -> UIColor
    var applySelectedTextColor: () -> UIColor
    var applyBackgroundColor: () -> UIColor
    var applySelectedBackgroundColor: () -> UIColor

    let nameButton: PaceTypeButton = PaceTypeButton()
    let textInput: UITextField = UITextField()
    let keyboardToolbar: UIToolbar = UIToolbar()
    let keyboardDoneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    let labelFontSize: CGFloat = 18
    let buttonTitle = "Custom distance"
    let bag = DisposeBag()

    public var isInputActive: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    public var distance: PublishRelay<Double> = PublishRelay()
    public var selectedDistance: PublishRelay<Double> = PublishRelay()

    init(applyTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColor,
         applySelectedTextColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellTextColorSelected,
         applyBackgroundColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellBackgroundColor,
         applySelectedBackgroundColor: @escaping @autoclosure () -> UIColor = AppEnvironment.current.theme.controlCellBackgroundColorSelected) {
        self.applyTextColor = applyTextColor
        self.applySelectedTextColor = applySelectedTextColor
        self.applyBackgroundColor = applyBackgroundColor
        self.applySelectedBackgroundColor = applySelectedBackgroundColor
        super.init(frame: .zero)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.applyTextColor = { AppEnvironment.current.theme.controlCellTextColor }
        self.applySelectedTextColor = { AppEnvironment.current.theme.controlCellTextColorSelected }
        self.applyBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColor }
        self.applySelectedBackgroundColor = { AppEnvironment.current.theme.controlCellBackgroundColorSelected }
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        setup()
        applyStyle()
    }

    public func updateDistance(_ distance: Double) {
        //show in same locale
        let number = NSNumber(value: distance)
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.numberStyle = NumberFormatter.Style.decimal

        textInput.text = formatter.string(from: number)
        isInputActive.accept(true)
    }

    func setup() {
        setupUI()
        setupActions()
    }

    func setupUI() {
        backgroundColor = .clear

        nameButton.translatesAutoresizingMaskIntoConstraints = false
        nameButton.setTitle(buttonTitle, for: .normal)
        addSubview(nameButton)

        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        keyboardToolbar.items = [flexBarButton, keyboardDoneButton]

        textInput.translatesAutoresizingMaskIntoConstraints = false
        textInput.accessibilityIdentifier = "textInput"
        textInput.borderStyle = UITextBorderStyle.none
        textInput.font = UIFont.systemFont(ofSize: labelFontSize)
        textInput.keyboardType = UIKeyboardType.decimalPad
        textInput.inputAccessoryView = keyboardToolbar
        textInput.textAlignment = .center
        addSubview(textInput)

        AutoLayoutUtils.constrainView(textInput, equalToView: self)
        AutoLayoutUtils.constrainView(nameButton, equalToView: self)
    }

    func setupActions() {
        nameButton.rx.tap
            .map { _ in true }
            .bind(to: isInputActive)
            .disposed(by: bag)

        isInputActive
            .subscribe(onNext: { [weak self] isActive in
                guard let _self = self else { return }
                self?.nameButton.setTitle(isActive ? " " : _self.buttonTitle, for: .normal)
                self?.textInput.isHidden = !isActive
                self?.applyStyle()
                if isActive { self?.textInput.becomeFirstResponder() }
            })
            .disposed(by: bag)

        textInput.rx.text.orEmpty
            .map(toDoubleUsingCurrentLocale)
            .ignoreNil()
            .bind(to: distance)
            .disposed(by: bag)

        keyboardDoneButton.rx.tap
            .withLatestFrom(textInput.rx.text.orEmpty)
            .map(toDoubleUsingCurrentLocale)
            .do(onNext: { [weak self] val in
                self?.textInput.resignFirstResponder()
                if val == nil { self?.isInputActive.accept(false) }
            })
            .ignoreNil()
            .bind(to: selectedDistance)
            .disposed(by: bag)
    }

    func applyStyle() {
        textInput.textColor = applySelectedTextColor()
        textInput.backgroundColor = applySelectedBackgroundColor()
    }

    public override var intrinsicContentSize: CGSize {
        return nameButton.intrinsicContentSize
    }

    @objc func themeDidChangeNotification(notification: Notification) {
        DispatchQueue.main.async {
            self.applyStyle()
        }
    }

}

extension CustomDistanceInput {
    public override func didMoveToWindow() {
        if self.window != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(themeDidChangeNotification), name: NSNotification.Name.ThemeDidChange, object: nil)
        }
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        if window == nil {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ThemeDidChange, object: nil)
        }
    }
}
