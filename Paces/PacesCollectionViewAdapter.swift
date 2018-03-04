//
//  PacesCollectionViewAdapter.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-19.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import PacesKit
import RxSwift
import RxCocoa

public class PacesCollectionViewAdapter: NSObject {

    // pace controls that act as the data source for the collection view
    fileprivate var paceControls: BehaviorRelay<[ConversionControl]> = BehaviorRelay(value: [])

    // weak reference to the collection being managed
    fileprivate weak var collectionView: UICollectionView?

    // partially applied closure that binds the control model to the input model
    fileprivate var bindControl: (_ control: PaceTypeControlViewModelType) -> ()

    // pan gesture used for panning control cells
    fileprivate var cellPanGesture: UIPanGestureRecognizer?

    // start point of pan action of the current actively panned cell
    fileprivate var cellPanStartPoint: CGPoint = .zero

    // actively panned cell
    fileprivate var activePannedCell: UICollectionViewCell? = nil

    // indexpath of the control being reconfigured
    fileprivate var reconfigureIndexPath: IndexPath? = nil

    init(_ collectionView: UICollectionView, bindControl: @escaping (PaceTypeControlViewModelType) -> () ) {
        self.collectionView = collectionView
        self.bindControl = bindControl
        super.init()
        // configure the cell pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleCellPan(_:)))
        panGesture.delegate = self
        self.collectionView?.addGestureRecognizer(panGesture)
        self.cellPanGesture = panGesture
    }

    // supplies data for the datasource
    func loadControls(_ controls: [ConversionControl]) {
        paceControls.accept(controls)
    }

    // update paceType for control at index
    func updatePaceType(_ paceType: PaceType, at index: Int) {
        guard let collectionView = collectionView else { return }
        let indexPath = IndexPath(row: index, section: 0)

        collectionView.performBatchUpdates({
            var items = paceControls.value
            if items.count > indexPath.item {
                var item = items.remove(at: indexPath.item)
                item.paceType = paceType
                items.insert(item, at: indexPath.item)
                paceControls.accept(items)

                reconfigureIndexPath = indexPath
                collectionView.reloadItems(at: [indexPath])
            }
        })
    }

}

extension PacesCollectionViewAdapter: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.paceControls.value.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let controlModel = paceControls.value[indexPath.item]

        var cell: UICollectionViewCell

        cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaceTypeControlCollectionViewCell.identifier, for: indexPath)
        if let paceTypeCell = cell as? PaceTypeControlCollectionViewCell {
            paceTypeCell.configureFor(control: controlModel)
            self.bindControl(paceTypeCell.paceTypeControlView.viewModel)
            paceTypeCell.paceTypeControlView.viewModel.controlIndex = { [weak self] control in
                return self?.paceControls.value.index(of: control)
            }
            // select control if it's being reconfigured
            if let reconfigureIndex = reconfigureIndexPath,
                reconfigureIndex == indexPath {
                reconfigureIndexPath = nil
                paceTypeCell.paceTypeControlView.viewModel.inputs.tapped.accept(())
            }
            print("bind item: \(indexPath.item)")
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView: UICollectionReusableView

        switch kind {
        case UICollectionElementKindSectionFooter: reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: AddControlView.identifier,
                                                                                      for: indexPath)
        default: reusableView = UICollectionReusableView(frame: .zero)
        }

        return reusableView
    }

}

extension PacesCollectionViewAdapter: UICollectionViewDelegate {
//    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("Starting Index: \(sourceIndexPath.item)")
//        print("Ending Index: \(destinationIndexPath.item)")
//    }
}

extension PacesCollectionViewAdapter: UICollectionViewDragDelegate {
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        let provider = NSItemProvider(object: "a" as NSString)
        let dragItem = UIDragItem(itemProvider: provider)

        dragItem.localObject = indexPath

        return [dragItem]
    }

}

extension PacesCollectionViewAdapter: UICollectionViewDropDelegate {
    public func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        //return session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String])
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
            let dragItem = coordinator.items.first?.dragItem,
            let sourceIndexPath = coordinator.items.first?.sourceIndexPath
            else { return }

        collectionView.performBatchUpdates({
            var items = paceControls.value
            let dragged = items.remove(at: sourceIndexPath.item)
            items.insert(dragged, at: destinationIndexPath.item)
            paceControls.accept(items)

            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        })

        //now tell coordinator to drop items at the specifuc destination
        coordinator.drop(dragItem, toItemAt: destinationIndexPath)
    }

}

extension PacesCollectionViewAdapter: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // start the cell pan if panning mostly horizontally
        if gestureRecognizer == cellPanGesture {
            guard let velocity = cellPanGesture?.velocity(in: cellPanGesture?.view) else { return true }
            //return fabs(velocity.x) > fabs(velocity.y);

            let radian = atan(velocity.y/velocity.x)
            let degree = Double(radian * 180) / Double.pi

            let thresholdAngle = 20.0
            if fabs(degree) > thresholdAngle {
                return false
            }
        }

        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("gesture: \(gestureRecognizer == cellPanGesture ? "cellPan" : String(describing: cellPanGesture))")
//        print("Other-gesture: \(otherGestureRecognizer == cellPanGesture ? "cellPan" : String(describing:otherGestureRecognizer))")

        return true
    }


    @objc public func handleCellPan(_ recognizer:UIPanGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)

        switch recognizer.state {
        case .began:
            print("began")
            guard let collectionView = recognizer.view as? UICollectionView,
                let indexpath = collectionView.indexPathForItem(at: point),
                let cell = collectionView.cellForItem(at: indexpath) as? ConversionControlCollectionViewCell
                else { return }

            activePannedCell = cell
            cellPanStartPoint = collectionView.convert(point, to: cell)
        case .changed:
            guard let collectionView = recognizer.view as? UICollectionView,
                let indexpath = collectionView.indexPathForItem(at: point),
                let cell = collectionView.cellForItem(at: indexpath) as? ConversionControlCollectionViewCell
                else { return }

            guard activePannedCell == cell else { return }

            let currentPoint =  collectionView.convert(point, to: cell)
            let deltaX = currentPoint.x - cellPanStartPoint.x

            cell.controlContentTrailingConstraint.constant = deltaX

            print("changed: \(currentPoint)")
        case .cancelled: fallthrough
        case .failed:
            if let controlCell = activePannedCell as? ConversionControlCollectionViewCell {
                controlCell.controlContentTrailingConstraint.constant = 0
            }
            activePannedCell = nil
        case .ended:
            print("ended")
            if let controlCell = activePannedCell as? ConversionControlCollectionViewCell {
                controlCell.controlContentTrailingConstraint.constant = 0
            }
            activePannedCell = nil
        default:
            break
        }


    }
}


