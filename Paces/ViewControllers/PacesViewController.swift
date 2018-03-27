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
import Action

protocol PacesViewControllerDelegate: class {
    func pacesViewControllerShowAbout(_ pacesViewController: PacesViewController)
}

class PacesViewController: UIViewController {

    weak var delegate:PacesViewControllerDelegate?
    let viewModel: PacesViewModelType = PacesViewModel()
    let bag = DisposeBag()

    let pickerView = UIPickerView()
    let paceInputView = PaceInputView(color: AppEnvironment.current.theme.inputViewBackgroundColor)
    let paceContentView = UIView()
    let gradientView = ThemeGradientView(applyGradientColors: AppEnvironment.current.theme.backgroundColorGradient)
    lazy var collectionView: UICollectionView = { UICollectionView(frame: CGRect.zero, collectionViewLayout: self.tableLayout()) }()
    lazy var collectionViewAdapter: PacesCollectionViewAdapter =  { createCollectionViewAdapter() }()
    lazy var inputSourceAnimator = UIViewPropertyAnimator(duration: inputAnimationDuration, dampingRatio: 0.8, animations: nil)
    var pickerBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    var paceContentBottomAnchor: NSLayoutConstraint = NSLayoutConstraint()

    let paceControlHeight: CGFloat = 80
    let pickerViewHeight: CGFloat = 200
    let paceControlSpacing: CGFloat = 5
    let inputAnimationDuration = 0.3
    let bounceAdjustment: CGFloat = 50

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindViewModel()

        viewModel.inputs.viewDidLoad.onNext(())
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

        // show or hide user input pane
        viewModel.outputs.showInput
            .skip(1)
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
            let pickerBottom = showInput ? 0 : strongSelf.paceInputView.bounds.size.height + strongSelf.bounceAdjustment
            let paceContentBottom = showInput ? -(strongSelf.pickerView.bounds.size.height + strongSelf.view.safeAreaInsets.bottom) : 0
            self?.pickerBottomConstraint.constant = pickerBottom
            self?.paceContentBottomAnchor.constant = paceContentBottom
            self?.view.layoutIfNeeded()
        }
        inputSourceAnimator.startAnimation()
    }

    func showConfigurePace(model: ConfigurePaceTypeViewModel) {
        let adding = model.paceType == nil
        let updateAction = Action<(Int, PaceType), Void> { [weak self] (id, paceType) in
            if adding {
                self?.collectionViewAdapter.addPaceType(paceType)
            }
            else {
                // editing a pace
                self?.collectionViewAdapter.updatePaceType(paceType, controlId: id)
            }
            return Observable.empty()
        }

        let deleteAction = Action<Int, Void>(enabledIf: Observable.just(!adding)) { [weak self] (id:Int) -> Observable<Void> in
            self?.collectionViewAdapter.deletePaceType(controlId: id)
            return .empty()
        }

        model.updateAction = updateAction
        model.deleteAction = deleteAction

        let configurePaceTypeView = ConfigurePaceTypeView.configuredWith(model)
        configurePaceTypeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(configurePaceTypeView)

        configurePaceTypeView.viewModel.outputs.configureFinished
            .take(1)
            .observeOnMain()
            .subscribe(onNext: { _ in
                configurePaceTypeView.removeFromSuperview()
            })
            .disposed(by: configurePaceTypeView.bag)

        NSLayoutConstraint.activate([
            configurePaceTypeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            configurePaceTypeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            configurePaceTypeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            configurePaceTypeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

        configurePaceTypeView.show()
    }

}

extension PacesViewController {
    func createCollectionViewAdapter() -> PacesCollectionViewAdapter {
        let pacesAdapter = PacesCollectionViewAdapter(collectionView,
                                                      bindControl: viewModel.bindControlModel(),
                                                      addPaceAction: viewModel.addPaceAction)
        pacesAdapter.adapterControls
            .bind(to: viewModel.inputs.paceControls)
            .disposed(by: viewModel.bag)

        return pacesAdapter
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
        let rootSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        pickerBottomConstraint.constant = pickerViewHeight + bounceAdjustment + (rootSafeArea ?? 0)
        pickerBottomConstraint.isActive = true

        NSLayoutConstraint.activate([
            paceContentView.leadingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.leadingAnchor),
            paceContentView.trailingAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.trailingAnchor),
            paceContentView.topAnchor.constraint(equalTo: gradientView.safeAreaLayoutGuide.topAnchor)
            ])
        paceContentBottomAnchor = paceContentView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor)
        paceContentBottomAnchor.isActive = true

        AutoLayoutUtils.constrainView(collectionView, equalToView: paceContentView)

    }

    func setupNavigationBar() {
        let aboutItem = UIBarButtonItem(image: UIImage(named: "iconBars"), style: .plain, target: nil, action: nil)
        let themeItem = UIBarButtonItem(image: UIImage(named: "eye"), style: .plain, target: nil, action: nil)
        themeItem.accessibilityLabel = "Toggle theme"
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Paces"
        navigationItem.leftBarButtonItem = aboutItem
        navigationItem.rightBarButtonItem = themeItem

        themeItem.rx.tap
            .map { _ in AppEnvironment.current.theme }
            .subscribe(onNext: { theme in
                let nextTheme = theme.themeType.toggle().theme()
                AppEnvironment.replaceCurrentEnvironment(theme: nextTheme)
                notifyThemeDidChange()
            })
            .disposed(by: bag)

        aboutItem.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let _self = self else { return }
                self?.delegate?.pacesViewControllerShowAbout(_self)
            })
            .disposed(by: bag)
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.dataSource = collectionViewAdapter
        collectionView.delegate = collectionViewAdapter
        collectionView.dragDelegate = collectionViewAdapter
        collectionView.dropDelegate = collectionViewAdapter
        collectionView.dragInteractionEnabled = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(PaceTypeControlCollectionViewCell.self,
                                forCellWithReuseIdentifier: PaceTypeControlCollectionViewCell.identifier)
        let nib = UINib(nibName: String(describing: AddControlView.self), bundle: Bundle(for: AddControlView.self))
        collectionView.register(nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: AddControlView.identifier)
        collectionView.allowsSelection = false
    }

}


extension PacesViewController {
    func test_printResources() {
        //print("resources: \(RxSwift.Resources.total)")
    }

    func test_printResources_doubleTap() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .debug("tapGesture")
            .subscribe { event in
                //print("resources: \(RxSwift.Resources.total)")
            }
            .disposed(by: bag)
    }

}

