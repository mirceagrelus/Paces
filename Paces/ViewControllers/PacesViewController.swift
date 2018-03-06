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
    let paceInputView = PaceInputView()
    let paceContentView = UIView()
    let gradientView = ThemeGradientView(applyGradientColors: AppEnvironment.current.theme.backgroundColorGradient)
    lazy var collectionView: UICollectionView = { UICollectionView(frame: CGRect.zero, collectionViewLayout: self.tableLayout()) }()
    lazy var collectionViewAdapter: PacesCollectionViewAdapter =  { createCollectionViewAdapter() }()
    lazy var inputSourceAnimator = UIViewPropertyAnimator(duration: inputAnimationDuration, dampingRatio: 0.8, animations: nil)
    var pickerBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var paceContentBottomAnchor: NSLayoutConstraint = NSLayoutConstraint()

    let paceControlHeight: CGFloat = 80 //70
    let pickerViewHeight: CGFloat = 200
    let paceControlSpacing: CGFloat = 5
    let inputAnimationDuration = 0.3
    let bounceAdjustment: CGFloat = 50

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

        //test_test()
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
        // update the pickerView data source
        viewModel.outputs.inputDataSource
            .observeOnMain()
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: bag)

        // update selection in picker when switching pace
        viewModel.inputs.inputPaceType
            .map { $0.displayValue }
            .observeOnMain()
            .subscribe(onNext: { [weak self] displayValue in
                self?.updatePickerValue(stringRepresentation: displayValue)
            })
            .disposed(by: bag)

        // convert selected picker values to an input string representation
        pickerView.rx.modelSelected(CustomStringConvertible.self)
            .withLatestFrom(viewModel.inputs.inputPaceType) { pickermodel, paceType -> String in
                return pickermodel.reduce("", { "\($0)\($1)" })
            }
            .filter { !$0.isEmpty }
            .bind(to: viewModel.inputs.inputValue)
            .disposed(by: bag)

        // load preexisting controls
        viewModel.outputs.paceControls
            .take(1)
            .subscribe(onNext: { [weak self] controls in
                self?.collectionViewAdapter.loadControls(controls)
                self?.collectionView.reloadData()
            })
            .disposed(by: bag)

        // show or hide user input pane
        viewModel.outputs.showInput
            .observeOnMain()
            .subscribe(onNext: { [weak self] showInput in
                self?.togglePaceInput(showInput)
            })
            .disposed(by: bag)

        // trigger initial value selection on first load
        viewModel.inputs.viewDidLoad
            .take(1)
            .withLatestFrom(viewModel.inputs.inputPaceType)
            .map { $0.displayValue }
            .bind(to: viewModel.inputs.inputValue)
            .disposed(by: bag)

        Observable.merge(
            viewModel.outputs.goToConfigurePace,
            viewModel.outputs.goToAddPaceType
            )
            .subscribe(onNext: { [weak self ] configureModel in
                self?.showConfigurePace(model: configureModel)
            })
            .disposed(by: bag)

    }

    func updatePickerValue(stringRepresentation paceValue: String) {
        print("== \(paceValue)")
        let first: String
        let second: String
        var third: String? = nil

        let components = paceValue.contains(":") ? paceValue.components(separatedBy: ":") :
                         paceValue.contains(".") ? paceValue.components(separatedBy: ".") : ["",""]

        guard components.count >= 2 else { return }
        first = components[0]
        second = components[1]
        if components.count >= 3 {
            third = components[2]
        }

        let comp1 = Int(first) ?? 0
        let comp2 = Int(second) ?? 0

        self.pickerView.selectRow(comp1, inComponent: 0, animated: true)
        self.pickerView.selectRow(comp2, inComponent: 2, animated: true)
        if let thirdVal = third {
            self.pickerView.selectRow(Int(thirdVal) ?? 0, inComponent: 4, animated: true)
        }
    }

    func togglePaceInput(_ showInput: Bool) {
        inputSourceAnimator.addAnimations { [weak self] in
            guard let strongSelf = self else { return }
            let const = showInput ? 0 : strongSelf.paceInputView.bounds.size.height + strongSelf.bounceAdjustment
            self?.pickerBottomConstraint.constant = const
            self?.paceContentBottomAnchor.constant = showInput ? -strongSelf.pickerView.bounds.size.height : 0
            self?.view.layoutIfNeeded()
        }
        inputSourceAnimator.startAnimation()
    }

    func showConfigurePace(model: ConfigurePaceTypeViewModel) {
        print("resources: \(RxSwift.Resources.total)")

        let configurePaceTypeView = ConfigurePaceTypeView.configuredWith(model)
        configurePaceTypeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(configurePaceTypeView)

        NSLayoutConstraint.activate([
            configurePaceTypeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            configurePaceTypeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            configurePaceTypeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            configurePaceTypeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        configurePaceTypeView.viewModel.outputs.paceTypeUpdated
            .take(1)
            .observeOnMain()
            .subscribe(onNext: { [weak self] (index, paceType) in
                if model.paceType == nil {
                    //adding a pace
                    self?.collectionViewAdapter.addPaceType(paceType)
                }
                else {
                    // editing a pace
                    self?.collectionViewAdapter.updatePaceType(paceType, at: index)
                }
            })
            .disposed(by: configurePaceTypeView.bag)

        configurePaceTypeView.viewModel.outputs.configureFinished
            .take(1)
            .observeOnMain()
            .subscribe(onNext: { _ in
                configurePaceTypeView.removeFromSuperview()
            })
            .disposed(by: configurePaceTypeView.bag)

        configurePaceTypeView.show()
    }


}

extension PacesViewController {
    func createCollectionViewAdapter() -> PacesCollectionViewAdapter {
        return PacesCollectionViewAdapter(collectionView,
                                          bindControl: viewModel.bindControlModel(),
                                          addPaceAction: viewModel.addPaceAction)
    }

    func tableLayout(width: CGFloat = 300) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
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

        paceInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(paceInputView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.showsSelectionIndicator = false
        paceInputView.addSubview(pickerView)

        paceContentView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.addSubview(paceContentView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        paceContentView.addSubview(collectionView)

        AutoLayoutUtils.constrainView(gradientView, equalToView: view)

        NSLayoutConstraint.activate([
            paceInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paceInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: paceInputView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: paceInputView.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: paceInputView.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: paceInputView.safeAreaLayoutGuide.bottomAnchor, constant: -bounceAdjustment),
            pickerView.heightAnchor.constraint(equalToConstant: pickerViewHeight)
            ])
        pickerBottomConstraint = pickerView.bottomAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.bottomAnchor)
        pickerBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            paceContentView.leadingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.leadingAnchor),
            paceContentView.trailingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.trailingAnchor),
            paceContentView.topAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.topAnchor)
            ])
        paceContentBottomAnchor = paceContentView.bottomAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.bottomAnchor)
        paceContentBottomAnchor.isActive = true

        AutoLayoutUtils.constrainView(collectionView, equalToView: paceContentView)

    }

    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Paces"
        let item = UIBarButtonItem(image: UIImage(named: "shortcut-icon-bars"), style: .plain, target: nil, action: nil)
        //let item = UIBarButtonItem(image: UIImage(named: "settings-icon"), style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = item

        item.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let _self = self else { return }
                self?.delegate?.pacesViewControllerShowSettings(_self)
            })
            .disposed(by: bag)

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
        collectionView.register(PaceTypeControlCollectionViewCell.self, forCellWithReuseIdentifier: PaceTypeControlCollectionViewCell.identifier)
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

}

