//
//  PickerViewAdapter.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-12.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class PickerViewViewAdapter : NSObject, UIPickerViewDataSource, UIPickerViewDelegate, RxPickerViewDataSourceType, SectionedViewDataSourceType {
    public typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    private let unit: PaceUnit
    private let staticUnitWidth: CGFloat = 20

    public init(unit: PaceUnit) {
        self.unit = unit
        super.init()
    }

    public func model(at indexPath: IndexPath) throws -> Any {
        return items[indexPath.section][indexPath.row]
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }

    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }

    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if items.count == 3 {
            if component == 1 { return staticUnitWidth }
            return (pickerView.bounds.size.width - staticUnitWidth) / 2.0
        }

        return pickerView.bounds.size.width / CGFloat(items.count)
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        //let contentView = UIView()
        //contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        //contentView.backgroundColor = UIColor.cyan
        let label = ThemeLabel(applyTextColor: AppEnvironment.current.theme.inputViewTextColor)
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.text = items[component][row].description
        //label.textColor = UIColor.white
        //label.backgroundColor = UIColor.green
        //label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.font = UIFont.systemFont(ofSize: 33)
        label.textAlignment = component == 0 ? .right : component == 1 ? .center : .left
        //label.textAlignment = .center

//        contentView.addSubview(label)
//        AutoLayoutUtils.constrainView(label, equalToGuide: contentView.layoutMarginsGuide)

        //return contentView
        return label

    }

    public func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}
