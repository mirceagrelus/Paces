//
//  PaceTypeControlView.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-27.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class PaceTypeControlView: UIView {

    public let viewModel: PaceTypeControlViewModelType = PaceTypeControlViewModel()
    public let bag: DisposeBag = DisposeBag()

    var paceControlView: PaceControlView?
    var distanceControlView: DistanceControlView?

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    public func commonInit() {
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .map { _ in () }
            .bind(to: viewModel.inputs.tapped)
            .disposed(by: bag)
    }

    public func configureFor(_ paceType: PaceType) {
        switch paceType {
        case .pace(_): self.addPaceControlView()
        case .race(_): self.addDistanceControlView()
        }

        self.viewModel.inputs.toPaceType.accept(paceType)
    }

    func addPaceControlView() {
        let paceView: PaceControlView = PaceControlView.fromNib()
        paceView.viewModel = viewModel.configuredPaceViewModel()
        self.paceControlView = paceView

        self.layoutControlView(paceView)
    }

    func addDistanceControlView() {
        let distanceView: DistanceControlView = DistanceControlView.fromNib()
        distanceView.viewModel = viewModel.configuredDistanceViewModel()
        self.distanceControlView = distanceView

        self.layoutControlView(distanceView)
    }

    func layoutControlView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        AutoLayoutUtils.constrainView(view, equalToView: self)
    }

}
