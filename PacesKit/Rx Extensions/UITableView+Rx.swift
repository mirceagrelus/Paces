//
//  Rx+Extensions.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-17.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {

    var nearBottom: Signal<()> {
        func isNearBottomEdge(tableView: UITableView, edgeOffset: CGFloat = 20.0) -> Bool {
            return tableView.contentOffset.y + tableView.frame.size.height + edgeOffset > tableView.contentSize.height
        }

        return self.contentOffset.asDriver()
            .flatMap { _ in
                return isNearBottomEdge(tableView: self.base, edgeOffset: 20.0)
                    ? Signal.just(())
                    : Signal.empty()
        }
    }
}
