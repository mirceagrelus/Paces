//
//  PacesViewController.swift
//  Paces
//
//  Created by Mircea Grelus on 2018-02-10.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import PacesKit
import RxSwift
import RxCocoa

protocol PacesViewControllerDelegate: class {
    func pacesViewControllerShowSettings(_ pacesViewController: PacesViewController)
}

class PacesViewController: UIViewController {

    weak var delegate:PacesViewControllerDelegate?
    let viewModel: PacesViewModelType = PacesViewModel()

    let gradientView: GradientView = GradientView()
    let pickerView: UIPickerView = UIPickerView()
    let paceContentView: UIView = UIView()
    let contentStack = UIStackView()
    let coontentStackFillView = UIView()
    let paceControlStack: UIStackView = UIStackView()
    var paceControls: [PaceControlView] = []
    let bag = DisposeBag()

    let paceControlHeight: CGFloat = 120
    let pickerViewHeight: CGFloat = 200
    let paceControlSpacing: CGFloat = 5

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        print("PacesViewController_deinit: \(RxSwift.Resources.total)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        bindViewModel()

        viewModel.inputs.viewDidLoad.onNext(())

        //test_removeControl()
        test_dismissController()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("resources: \(RxSwift.Resources.total)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext(())
        print("resources_viewWillDisappear: \(RxSwift.Resources.total)")
    }

    func bindViewModel() {

        // setup the pickerView data source according to the  PaceUnit
        viewModel.inputs.switchUserInputPace
            .map { $0.unit.inputSource }
            .debug("switchPickerDatasource")
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter(unit: viewModel.inputs.paceUnit.value)))
            .disposed(by: bag)

        // update selection in picker when switching pace
        viewModel.inputs.switchUserInputPace
            .map { $0.displayValue }
            .debug("selectPickerValue")
            .subscribe(onNext: { [weak self] displayValue in
                self?.updatePickerValue(stringRepresentation: displayValue)
            })
            .disposed(by: bag)

        // convert selected picker pace to a Pace value
        pickerView.rx.modelSelected(CustomStringConvertible.self)
            .withLatestFrom(viewModel.inputs.paceUnit) { pickermodel, paceUnit -> String in
                return pickermodel.reduce("", { "\($0)\($1)" })
            }
            .debug("pickerSelected")
            .filter { !$0.isEmpty }
            .bind(to: viewModel.inputs.paceValue)
            .disposed(by: bag)

        // recreate the PaceControlViews that were used last time the app was opened
        let archivedControls = viewModel.outputs.archivedUnits
            .flatMap { Observable.from($0) }
            .map { PaceControlView.createWithPaceUnit($0) }
            .map { self.bindControlModel(control: $0) }
            .toArray()
            .debug("archivedControls")
            .share(replay: 1, scope: .whileConnected)

        // add controls to UI
        archivedControls
            //.map { $0.map { $0.0 } }
            .subscribe(onNext: { controls in
                self.paceControls = controls
                self.addPaceControlViews(controls)
            })
            .disposed(by: bag)

        // restore last input pace
        archivedControls
            .ignoreElements()
            .andThen(
                Observable.combineLatest(viewModel.inputs.paceValue, viewModel.inputs.paceUnit, resultSelector: { ($0, $1) })
            )
            .debug("afterLoad")
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { tupple in
                let (paceValue, _) = tupple
                self.updatePickerValue(stringRepresentation: paceValue)
                self.changePaceValue(stringRepresentation: self.viewModel.inputs.paceValue.value)
            })
            .disposed(by: bag)


//        self.rx.methodInvoked(#selector(viewDidLoad))
//            .subscribe { event in
//                print("methodInvoked - viewDidLoad: \(event)")
//        }
//        .disposed(by: bag)

    }

    func bindControlModel(control: PaceControlView) -> PaceControlView {
        self.viewModel.outputs.pace
            .debug("control-pace")
            .bind(to: control.viewModel.inputs.fromPace)
            .disposed(by: control.bag)

        control.viewModel.outputs.switchUserInputPace
            .debug("control-switchInputPace")
            .bind(to: viewModel.inputs.switchUserInputPace)
            .disposed(by: control.bag)

        return control
    }

    func changeUnit(_ unit: PaceUnit) {
        viewModel.inputs.paceUnit.accept(unit)
    }

    func changePaceValue(stringRepresentation: String) {
        viewModel.inputs.paceValue.accept(stringRepresentation)
    }

    func addPaceControlViews(_ views: [PaceControlView]) {
        views.forEach { (control) in
            control.heightAnchor.constraint(equalToConstant: paceControlHeight).isActive = true
            paceControlStack.addArrangedSubview(control)
        }
    }

    func updatePickerValue(stringRepresentation paceValue: String) {
        print("== \(paceValue)")
        let min: String
        let sec: String

        let components = paceValue.contains(":") ? paceValue.components(separatedBy: ":") :
                         paceValue.contains(".") ? paceValue.components(separatedBy: ".") : ["",""]

        guard components.count >= 2 else { return }
        min = components[0]
        sec = components[1]

        let first = Int(min) ?? 0
        let second = Int(sec) ?? 0

        self.pickerView.selectRow(first, inComponent: 0, animated: true)
        self.pickerView.selectRow(second, inComponent: 2, animated: true)
    }


}

extension PacesViewController {
    func test_printResources() {
        print("resources: \(RxSwift.Resources.total)")
    }

    func test_dismissController() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .debug("tapGesture")
            .subscribe { [weak self] event in
                self?.test_printResources()
                self?.delegate?.pacesViewControllerShowSettings(self!)
                self?.test_printResources()
            }
            .disposed(by: bag)
    }

    func test_removeControl() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .subscribe { [unowned self] event in
                print(event)
                self.test_printResources()

                let control = self.paceControlStack.arrangedSubviews[1] as! PaceControlView
                control.removeFromSuperview()
                self.paceControls = self.paceControls.filter { $0 != control }

                self.test_printResources()
            }
            .disposed(by: bag)
    }
}

extension PacesViewController {
    func setup() {
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.insertGradient(topToBottom: true, colorArray: [UIColor.orange, UIColor.red])
        view.addSubview(gradientView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.showsSelectionIndicator = false
        gradientView.addSubview(pickerView)

        paceContentView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(paceContentView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        paceContentView.addSubview(contentStack)

        paceControlStack.translatesAutoresizingMaskIntoConstraints = false
        paceControlStack.axis = .vertical
        paceControlStack.distribution = .equalSpacing
        paceControlStack.spacing = paceControlSpacing
        contentStack.addArrangedSubview(paceControlStack)

        coontentStackFillView.translatesAutoresizingMaskIntoConstraints = false
        //coontentStackFillView.backgroundColor = UIColor.purple
        contentStack.addArrangedSubview(coontentStackFillView)


        AutoLayoutUtils.constrainView(gradientView, equalToView: view)

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.bottomAnchor)
            ])

        NSLayoutConstraint.activate([
            paceContentView.leadingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.leadingAnchor),
            paceContentView.trailingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.trailingAnchor),
            paceContentView.topAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.topAnchor),
            paceContentView.bottomAnchor.constraint(equalTo: pickerView.topAnchor)
            ])


        AutoLayoutUtils.constrainView(contentStack, equalToView: paceContentView)
    }

}
