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
    let bag = DisposeBag()

    let pickerView = UIPickerView()
    let paceContentView = UIView()
    let gradientView = ThemeGradientView(applyGradientColors: AppEnvironment.current.theme.backgroundColorGradient)
    lazy var collectionView: UICollectionView = { UICollectionView(frame: CGRect.zero, collectionViewLayout: self.tableLayout()) }()
    lazy var collectionViewAdapter: PacesCollectionViewAdapter =  { createCollectionViewAdapter() }()

    let paceControlHeight: CGFloat = 80 //70
    let pickerViewHeight: CGFloat = 200
    let paceControlSpacing: CGFloat = 5

    fileprivate let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        print("PacesViewController_deinit: \(RxSwift.Resources.total)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        bindViewModel()

        viewModel.inputs.viewDidLoad.onNext(())

        //test_removeControl()
//        test_dismissController()
        test_test()
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
            .observeOnMain()
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter(unit: viewModel.inputs.paceUnit.value)))
            .disposed(by: bag)

        // update selection in picker when switching pace
        viewModel.inputs.switchUserInputPace
            .map { $0.displayValue }
            .debug("selectPickerValue")
            .observeOnMain()
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

        // load initial controls
        viewModel.outputs.paceControls
            .take(1)
            .subscribe(onNext: { [weak self] controls in
                self?.collectionViewAdapter.loadControls(controls)
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)

        viewModel.outputs.showInput
            .observeOnMain()
            .subscribe(onNext: { [weak self] showInput in
                print("showInput: \(showInput)")
                self?.pickerView.isHidden = !showInput
            })
            .disposed(by: bag)

    }

    func changeUnit(_ unit: PaceUnit) {
        viewModel.inputs.paceUnit.accept(unit)
    }

    func changePaceValue(stringRepresentation: String) {
        viewModel.inputs.paceValue.accept(stringRepresentation)
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
    func createCollectionViewAdapter() -> PacesCollectionViewAdapter {
        return PacesCollectionViewAdapter(collectionView) { [weak self] control in
            guard let weakSelf = self else { return }

            weakSelf.viewModel.outputs.pace
                .debug("control-pace")
                .bind(to: control.viewModel.inputs.fromPace)
                .disposed(by: control.bag)

            control.viewModel.outputs.switchUserInputPace
                .debug("control-switchInputPace")
                .bind(to: weakSelf.viewModel.inputs.switchUserInputPace)
                .disposed(by: control.bag)

            weakSelf.viewModel.inputs.switchUserInputPace
                .withLatestFrom(control.viewModel.inputs.toUnit, resultSelector: { $0.unit == $1 })
                .bind(to: control.viewModel.inputs.isSource)
                .disposed(by: control.bag)

            // trigger initial value
            control.viewModel.inputs.fromPace.accept(weakSelf.viewModel.outputs.lastPace)
        }
    }

    func tableLayout(width: CGFloat = 300) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        //PaceControlCollectionViewCell.width = width
        //let width = PaceControlCollectionViewCell.width
        let width = self.view.bounds.size.width
        layout.itemSize = CGSize(width: width, height: self.paceControlHeight)
        layout.footerReferenceSize = CGSize(width: width, height: self.paceControlHeight)
        layout.minimumLineSpacing = 2.0

        return layout
    }

}

extension PacesViewController {
    func setup() {
        setupNavigationBar()
        setupCollectionView()

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        pickerView.showsSelectionIndicator = false
        gradientView.addSubview(pickerView)

        paceContentView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(paceContentView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        paceContentView.addSubview(collectionView)

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


        AutoLayoutUtils.constrainView(collectionView, equalToView: paceContentView)
    }

    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Paces"
        let item = UIBarButtonItem(image: UIImage(named: "shortcut-icon-bars"), style: .plain, target: nil, action: nil)
        //let item = UIBarButtonItem(image: UIImage(named: "settings-icon"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = item

        self.toolbarItems = [item]
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = collectionViewAdapter
        collectionView.delegate = collectionViewAdapter
        collectionView.dragDelegate = collectionViewAdapter
        collectionView.dropDelegate = collectionViewAdapter
        collectionView.dragInteractionEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(DistanceControlCollectionViewCell.self, forCellWithReuseIdentifier: DistanceControlCollectionViewCell.identifier)
        collectionView.register(PaceControlCollectionViewCell.self, forCellWithReuseIdentifier: PaceControlCollectionViewCell.identifier)
        let nib = UINib(nibName: String(describing: AddControlView.self), bundle: Bundle(for: AddControlView.self))
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: AddControlView.identifier)
        collectionView.allowsSelection = false
    }

}


extension PacesViewController {
    func test_printResources() {
        print("resources: \(RxSwift.Resources.total)")
    }

    func test_test() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .debug("tapGesture")
            .subscribe { event in

                print("resources: \(RxSwift.Resources.total)")

            }
            .disposed(by: bag)

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
}

