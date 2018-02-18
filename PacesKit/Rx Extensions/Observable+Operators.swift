//
//  Observable+Operators.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-17.
//  Copyright © 2018 CodexBit Software. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {

    public func observeOnMain() -> Observable<E> {
        return self.observeOn(MainScheduler.instance)
    }

}

