//
//  AppEnvironment.swift
//  PacesKit
//
//  Created by Mircea Grelus on 2018-02-09.
//  2018 CodexBit Software
//
// Uses the AppEnvironment model of handling dependencies used in the Kickstarter-iOS app
// https://github.com/kickstarter/ios-oss/blob/master/Library/AppEnvironment.swift

import Foundation

public struct AppEnvironment {
    internal static let environmentStorageKey = "com.Paces.AppEnvironment.current"

    internal static let key_themeType = "themeType"
    internal static let key_isPremiumUser = "isPremiumUser"
    internal static let key_inputPaceValue = "inputPaceValue"
    internal static let key_inputPaceUnit = "inputPaceUnit"

    // A global stack of environments.
    fileprivate static var stack: [Environment] = [Environment()]

    // The latest stack environment on the stack
    public static var current: Environment {
        return stack.last!
    }

    // Push a new environment onto the stack.
    internal static func pushEnvironment(_ env: Environment) {
        saveEnvironment(environment: env, userDefaults: env.userDefaults)
        stack.append(env)
    }

    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }

    // Replaces the current environment onto the stack with an environment that changes only a subset of current global dependencies.
    public static func replaceCurrentEnvironment(theme: Theme = current.theme,
                                                 isPremiumUser: Bool = current.isPremiumUser,
                                                 inputPaceValue: String = current.inputPaceValue,
                                                 inputPaceUnit: PaceUnit = current.inputPaceUnit,
                                                 ubiquitousStore: KeyValueStoreType = current.ubiquitousStore,
                                                 userDefaults: KeyValueStoreType = current.userDefaults) {

        replaceCurrentEnvironment(
            Environment(theme: theme,
                        isPremiumUser: isPremiumUser,
                        inputPaceValue: inputPaceValue,
                        inputPaceUnit: inputPaceUnit,
                        ubiquitousStore: ubiquitousStore,
                        userDefaults: userDefaults)
        )
    }

    // Returns the last saved environment from user defaults.
    public static func fromStorage(userDefaults: KeyValueStoreType) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]

        let themeId = data[key_themeType] as? Int ?? 0
        let theme = ThemeType(rawValue: themeId)?.theme()

        let isPremiumUser = data[key_isPremiumUser] as? Bool

        let inputPaceUnitDescription = data[key_inputPaceUnit] as? String ?? ""
        let inputPaceUnit = PaceUnit.fromDescription(inputPaceUnitDescription)

        let inputPaceValue = data[key_inputPaceValue] as? String

        return Environment(theme: theme ?? current.theme,
                           isPremiumUser: isPremiumUser ?? current.isPremiumUser,
                           inputPaceValue: inputPaceValue ?? current.inputPaceValue,
                           inputPaceUnit: inputPaceUnit ?? current.inputPaceUnit)
    }

    // Saves some key data for the current environment
    internal static func saveEnvironment(environment env: Environment,
                                         userDefaults: KeyValueStoreType) {

        var data: [String: Any] = [:]

        data[key_themeType] = env.theme.themeType.rawValue

        data[key_isPremiumUser] = env.isPremiumUser
        data[key_inputPaceUnit] = env.inputPaceUnit.description
        data[key_inputPaceValue] = env.inputPaceValue

        userDefaults.set(data, forKey: environmentStorageKey)

    }
}
