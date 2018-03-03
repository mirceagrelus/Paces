//
//  Environment.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-09.
//  2018 CodexBit Software.
//

import Foundation

public struct Environment {

    // theme of the app
    public let theme: Theme

    // Identifies whether the current user has purchased the Premium IAP
    public let isPremiumUser: Bool

    // last input value used
    public let inputValue: String

    // the last pace type that was used for input data
    public let inputPaceType: PaceType

    // last version number the What's new info was shown for
    public let lastVersionWhatsNewShown: Double

    /// A local key-value store. Default is `UserDefaults.standard`
    public let userDefaults: KeyValueStoreType

    /// A ubiquitous key-value store. Default value is `NSUbiquitousKeyValueStore.default`.
    public let ubiquitousStore: KeyValueStoreType

    // current version for the What's New info screen
    public let whatsNewVersion: Double = 1.0

    public init(
        theme: Theme = ThemeType.orangeRed.theme(),
        isPremiumUser: Bool = false,
        inputValue: String = "8:00",
        inputPaceType: PaceType = .pace(Pace.minPerMile(seconds: 8*60)),
        lastVersionWhatsNewShown: Double = 0,
        ubiquitousStore: KeyValueStoreType = NSUbiquitousKeyValueStore.default,
        userDefaults: KeyValueStoreType = UserDefaults.standard){

        self.theme = theme
        self.isPremiumUser = isPremiumUser
        self.inputValue = inputValue
        self.inputPaceType = inputPaceType
        self.lastVersionWhatsNewShown = lastVersionWhatsNewShown
        self.ubiquitousStore = ubiquitousStore
        self.userDefaults = userDefaults
    }
}
