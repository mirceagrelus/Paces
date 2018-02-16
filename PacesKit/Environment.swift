//
//  Environment.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-09.
//  2018 CodexBit Software.
//

import Foundation

public struct Environment {

    // Identifies whether the current user has purchased the Premium IAP
    public let isPremiumUser: Bool

    // last pace value used
    public let inputPaceValue: String

    // the last pace unit that was used for input data
    public let inputPaceUnit: PaceUnit

    /// A local key-value store. Default is `UserDefaults.standard`
    public let userDefaults: KeyValueStoreType

    /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
    public let ubiquitousStore: KeyValueStoreType

    public init(
        isPremiumUser: Bool = false,
        inputPaceValue: String = "8:00",
        inputPaceUnit: PaceUnit = .minPerMile,
        ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default,
        userDefaults: KeyValueStoreType = UserDefaults.standard){

        self.isPremiumUser = isPremiumUser
        self.inputPaceValue = inputPaceValue
        self.inputPaceUnit = inputPaceUnit
        self.ubiquitousStore = ubiquitousStore
        self.userDefaults = userDefaults
    }
}
