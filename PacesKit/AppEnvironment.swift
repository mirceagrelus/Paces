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
    public static func replaceCurrentEnvironment(isPremiumUser: Bool = current.isPremiumUser,
                                                 ubiquitousStore: KeyValueStoreType = current.ubiquitousStore,
                                                 userDefaults: KeyValueStoreType = current.userDefaults) {

        replaceCurrentEnvironment(
            Environment(isPremiumUser: isPremiumUser,
                        ubiquitousStore: ubiquitousStore,
                        userDefaults: userDefaults)
        )
    }

    // Returns the last saved environment from user defaults.
    public static func fromStorage(userDefaults: KeyValueStoreType) -> Environment {
        let data = userDefaults.dictionary(forKey: environmentStorageKey) ?? [:]
        let isPremiumUser = data["isPremiumUser"] as? Bool
        return Environment(isPremiumUser: isPremiumUser ?? current.isPremiumUser)
    }

    // Saves some key data for the current environment
    internal static func saveEnvironment(environment env: Environment,
                                         userDefaults: KeyValueStoreType) {

        var data: [String: Any] = [:]

        data["isPremiumUser"] = env.isPremiumUser

        userDefaults.set(data, forKey: environmentStorageKey)

    }
}
