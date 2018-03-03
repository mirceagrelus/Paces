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

/*
 https://github.com/artsy/eidolon/blob/24e36a69bbafb4ef6dbe4d98b575ceb4e1d8345f/Kiosk/Observable%2BOperators.swift#L30-L40
 **/
public protocol OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

public extension Observable where Element: OptionalType {
    public func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }

    public func replaceNilWith(nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}
