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
    internal static let key_inputPaceType = "inputPaceType"
    internal static let key_archivedControls = "archivedControls"
    internal static let key_lastVersionWhatsNewShown = "lastVersionWhatsNewShown"

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

    // Pop an environment off the stack.
    @discardableResult
    public static func popEnvironment() -> Environment? {
        let last = stack.count > 1 ? stack.popLast() : nil
        if last != nil {
            saveEnvironment(environment: current,
                            userDefaults: current.userDefaults)
        }
        return last
    }

    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: Environment) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }

    // Replaces the current environment onto the stack with an environment that changes only a subset of current global dependencies.
    public static func replaceCurrentEnvironment(theme: Theme = current.theme,
                                                 isPremiumUser: Bool = current.isPremiumUser,
                                                 inputValue: String = current.inputValue,
                                                 inputPaceType: PaceType = current.inputPaceType,
                                                 archivedControls: [ConversionControl] = current.archivedControls,
                                                 lastVersionWhatsNewShown: Double = current.lastVersionWhatsNewShown,
                                                 ubiquitousStore: KeyValueStoreType = current.ubiquitousStore,
                                                 userDefaults: KeyValueStoreType = current.userDefaults) {

        replaceCurrentEnvironment(
            Environment(theme: theme,
                        isPremiumUser: isPremiumUser,
                        inputValue: inputValue,
                        inputPaceType: inputPaceType,
                        archivedControls: archivedControls,
                        lastVersionWhatsNewShown: lastVersionWhatsNewShown,
                        ubiquitousStore: ubiquitousStore,
                        userDefaults: userDefaults)
        )
    }

    // Returns the last saved environment from user defaults.
    public static func fromStorage(userDefaults: KeyValueStoreType) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]

        let themeId = data[key_themeType] as? String ?? ""
        let theme = ThemeType(rawValue: themeId)?.theme()

        let isPremiumUser = data[key_isPremiumUser] as? Bool

        let inputValue = data[key_inputPaceValue] as? String

        var inputPaceType: PaceType? = nil
        do {
            if let jsonString = data[key_inputPaceType] as? String,
                let jsonData = jsonString.data(using: .utf8) {
                
                inputPaceType = try JSONDecoder().decode(PaceType.self, from: jsonData)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        var archivedControls: [ConversionControl]?
        do {
            if let jsonString = data[key_archivedControls] as? String,
                let jsonData = jsonString.data(using: .utf8) {

                let archivedPaceTypes = try JSONDecoder().decode(Array<PaceType>.self, from: jsonData)
                archivedControls = archivedPaceTypes.enumerated().map { ConversionControl(id: $0, paceType: $1) }
            }
        }
        catch {
            print(error.localizedDescription)
        }

        let lastVersionWhatsNewShown = data[key_lastVersionWhatsNewShown] as? Double


        return Environment(theme: theme ?? current.theme,
                           isPremiumUser: isPremiumUser ?? current.isPremiumUser,
                           inputValue: inputValue ?? current.inputValue,
                           inputPaceType: inputPaceType ?? current.inputPaceType,
                           archivedControls: archivedControls ?? current.archivedControls,
                           lastVersionWhatsNewShown: lastVersionWhatsNewShown ?? current.lastVersionWhatsNewShown)
    }

    // Saves some key data for the current environment
    internal static func saveEnvironment(environment env: Environment,
                                         userDefaults: KeyValueStoreType) {

        var data: [String: Any] = [:]

        data[key_themeType] = env.theme.themeType.rawValue

        data[key_isPremiumUser] = env.isPremiumUser
        data[key_inputPaceValue] = env.inputValue

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(env.inputPaceType)
            let jsonString = String(decoding: jsonData, as: UTF8.self)

            data[key_inputPaceType] = jsonString
        }
        catch {
            print(error.localizedDescription)
        }

        do {
            let encoder = JSONEncoder()
            let archivedControlsData = try encoder.encode(env.archivedControls.map { $0.paceType })
            let jsonString = String(decoding: archivedControlsData, as: UTF8.self)

            data[key_archivedControls] = jsonString
        }
        catch {
            print(error.localizedDescription)
        }

        data[key_lastVersionWhatsNewShown] = env.lastVersionWhatsNewShown

        userDefaults.set(data, forKey: environmentStorageKey)

    }
}
